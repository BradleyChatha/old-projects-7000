#include "ASTNodes.h"

///For ease functions
namespace
{
	///Checks the tokens and then pops the front token
	void EnforceToken(Lexer &lexer, TokenType type)
	{
		if (!lexer.FrontToken().IsType(type))
			throw runtime_error("Unexpected Token");
		lexer.PopFront();
	}

	///Makes sure for just semicolons.
	void EnforceSemicolon(Lexer &lexer)
	{
		if (!lexer.FrontToken().IsType(TokenType::TOKENTYPE_OPERATOR_SEMICOLON))
			throw runtime_error("End of operation not found.");
		lexer.PopFront();
	}
}

///Reads a variable declaration line. (e.g. var MyInt as int = 10;)
ASTNode_Variable ReadVariable(Lexer &lexer)
{
	ASTNode_Variable VariableNode;

	///Check for "Var"
	EnforceToken(lexer, TokenType::TOKENTYPE_KEYWORD_VAR);

	///Check that it is a name that is given.
	Token Name = lexer.FrontToken();
	if(!Name.IsType(TokenType::TOKENTYPE_IDENTIFIER))
		throw runtime_error("Unexpected Token");
	lexer.PopFront();
	VariableNode.Name = Name;

	///Check for "as"
	EnforceToken(lexer, TokenType::TOKENTYPE_KEYWORD_AS);
	
	///Check if is any of these types
	///An (u)integer, (u)byte, float, string, indetifier (classes).
	Token Type = lexer.FrontToken();
	if (!Type.IsAnyOf({TokenType::TOKENTYPE_KEYWORD_INT, TokenType::TOKENTYPE_KEYWORD_UINT, TokenType::TOKENTYPE_KEYWORD_BYTE, 
					   TokenType::TOKENTYPE_KEYWORD_UBYTE, TokenType::TOKENTYPE_KEYWORD_FLOAT, TokenType::TOKENTYPE_KEYWORD_STRING, TokenType::TOKENTYPE_IDENTIFIER}))
		throw runtime_error("Unexpected Token");
	lexer.PopFront();

	///---Optional---
	///Checks if there is a value being assigned to it.
	if(lexer.FrontToken().IsType(TokenType::TOKENTYPE_OPERATOR_EQUALS))
	{
		lexer.PopFront();

		///Get the value assigned
		Token Value = lexer.FrontToken();

		///Check if is any of these types
		///An (u)integer, (u)byte, float, string, indetifier (classes).
		if (Value.IsAnyOf({ TokenType::TOKENTYPE_STRING, TokenType::TOKENTYPE_IDENTIFIER, TokenType::TOKENTYPE_NUMBER }))
		{
			switch (Name.Type)
			{
			case TokenType::TOKENTYPE_STRING:
				VariableNode.Value = ASTNode_String(Value);
				break;

			case TokenType::TOKENTYPE_NUMBER:
				VariableNode.Value = ASTNode_Number(Value);
				break;

			case TokenType::TOKENTYPE_IDENTIFIER:
				VariableNode.Value = ASTNode_UserDefined(Value);
				break;
			}
		}
		else
			throw runtime_error("Unexpected Token");

		lexer.PopFront();
	}

	EnforceSemicolon(lexer);
	return VariableNode;
}
