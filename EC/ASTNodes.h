#pragma once

#include <string>
#include "Lexer.h"
#include "Token.h"

using namespace std;

///The different types of nodes that there are.
enum class ASTNodeType
{
	NODETYPE_VARIABLE = 0,
	NODETYPE_STRING,
	NODETYPE_NUMBER,
	NODETYPE_USERDEFINED ///For classes etc.. There wont be a node of this, just need somewhere to put it.
};

class ASTNode
{
public:
	string Data;
	ASTNodeType Type;
};

///A base for variable types
class ASTNode_VariableBase : public ASTNode
{
public:
	Token Value;
};

///For when variables are made.
class ASTNode_Variable : public ASTNode
{
public:
	Token Name;
	ASTNode_VariableBase Value;
};

///For string type variables
class ASTNode_String : public ASTNode_VariableBase
{
public:
	ASTNode_String(Token value)
	{
		this->Value = value;
		this->Type = ASTNodeType::NODETYPE_STRING;
	}
};

///For numbers
class ASTNode_Number : public ASTNode_VariableBase
{
public:
	ASTNode_Number(Token value)
	{
		this->Value = value;
		this->Type = ASTNodeType::NODETYPE_NUMBER;
	}
};

///User defined types
class ASTNode_UserDefined : public ASTNode_VariableBase
{
public:
	ASTNode_UserDefined(Token value)
	{
		this->Value = value;
		this->Type = ASTNodeType::NODETYPE_USERDEFINED;
	}
};


extern ASTNode_Variable ReadVariable(Lexer &lexer);