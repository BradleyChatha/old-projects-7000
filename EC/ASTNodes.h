#pragma once

#include <string>
#include <iostream>
#include <vector>
#include "Lexer.h"
#include "Token.h"

using namespace std;

///The different types of nodes that there are.
enum class ASTNodeType
{
	NODETYPE_VARIABLE = 0,
	NODETYPE_STRING,
	NODETYPE_NUMBER,
	NODETYPE_USERDEFINED, ///For classes, namespaces etc..
	NODETYPE_NAMESAPCE
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

///For namespaces
class ASTNode_Namespace : public ASTNode
{
public:
	Token Namespace;
	ASTNode_VariableBase Name;
};

///For creating functions
class ASTNode_Function : public ASTNode
{
public:
	Token Function;
	Token ReturnType;
	vector<ASTNode_Variable> Parameters;
	///TODO: Add if statement nodes when they're made.
	///TODO: Think of way to contain function body.
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

	ASTNode_UserDefined() {}
};

///TODO: Make a function to handle the different ways that identifiers can just be there:
/// - Function definitions.
/// - Non member function calls.
/// - Variable reassignmeny.
/// - Object reassignment.
/// - Object member variable access.
/// - Object memeber function call.

extern ASTNode_Variable ReadVariable(Lexer &lexer);
extern ASTNode_Namespace ReadNamespace(Lexer &lexer);
extern ASTNode_Function ReadDefineFunction(Lexer &lexer);