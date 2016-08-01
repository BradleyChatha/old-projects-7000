#pragma once

#include <string>
#include "Token.h"

using namespace std;

///The different types of nodes that there are.
enum class ASTNodeType
{
	NODETYPE_VARIABLE = 0,
	NODETYPE_STRING,
	NODETYPE_INTEGER,
	NODETYPE_FLOATINGPOINT
};

///The base for all node.
class ASTNode
{
public:
	string Data;
	Token TokenData;
	ASTNodeType Type;
};

///For when variables are made.
class ASTNode_Variable : ASTNode
{
public:
	ASTNode VariableData;
};

///For string type variables
class ASTNode_String : ASTNode
{
public:
	ASTNode_String();
};

