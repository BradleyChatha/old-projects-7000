#include "ASTNodes.h"

///For ease functions
namespace
{
	///Checks the tokens and then pops the front token. Returns the then front token
	Token EnforceToken(Lexer &lexer, TokenType type)
	{
		Token tok = lexer.FrontToken();
		if (!tok.IsType(type))
			throw runtime_error("Unexpected Token");
		lexer.PopFront();

		return tok;
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
	VariableNode.Name = EnforceToken(lexer, TokenType::TOKENTYPE_IDENTIFIER);

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
		if (Value.IsAnyOf({ TokenType::TOKENTYPE_STRING, TokenType::TOKENTYPE_IDENTIFIER, TokenType::TOKENTYPE_NUMBER,  TokenType::TOKENTYPE_OPERATOR_SUBTRACTION}))
		{
			///Because C++ is rude and this is for negative numbers.
			Token Number;

			switch (Value.Type)
			{
			case TokenType::TOKENTYPE_STRING:
				VariableNode.Value = ASTNode_String(Value);
				break;

			case TokenType::TOKENTYPE_NUMBER:
				VariableNode.Value = ASTNode_Number(Value);
				break;

			case TokenType::TOKENTYPE_OPERATOR_SUBTRACTION:
				///The negation is lost because of the way the lexer works so it needs to be re-added.
				lexer.PopFront();
				Number = lexer.FrontToken();
				Number.TokenData.insert(0, "-");

				VariableNode.Value = ASTNode_Number(Number);
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

ASTNode_Namespace ReadNamespace(Lexer &lexer)
{
	ASTNode_Namespace NamespaceNode;

	///Check for "namespace".
	Token Namespace = EnforceToken(lexer, TokenType::TOKENTYPE_KEYWORD_NAMESPACE);
	NamespaceNode.Namespace = Namespace;

	///Check for its name (e.g. namespace SuperComplexMath;)
	Token NamespaceName = EnforceToken(lexer, TokenType::TOKENTYPE_IDENTIFIER);
	NamespaceNode.Name = ASTNode_UserDefined(NamespaceName);

	///Check for the semicolon.
	EnforceSemicolon(lexer);
	return NamespaceNode;
}