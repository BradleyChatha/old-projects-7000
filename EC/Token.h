#pragma once

#include <iostream>
#include <string>
#include "TokenType.h"

using namespace std;

	///For lazy debugging.
const string TokenTypeNames[] = { "TOKENTYPE_KEYWORD_NAMESPACE", "TOKENTYPE_KEYWORD_CLASS", "TOKENTYPE_KEYWORD_RETURN", "TOKENTYPE_KEYWORD_IF", 
								"TOKENTYPE_KEYWORD_ELIF", "TOKENTYPE_KEYWORD_ELSE", "TOKENTYPE_KEYWORD_WHILE", "TOKENTYPE_KEYWORD_FOR", 
								"TOKENTYPE_KEYWORD_VAR", "TOKENTYPE_KEYWORD_INT", "TOKENTYPE_KEYWORD_UINT", "TOKENTYPE_KEYWORD_BYTE", 
								"TOKENTYPE_KEYWORD_UBYTE", "TOKENTYPE_KEYWORD_STRING", "TOKENTYPE_KEYWORD_FLOAT", "TOKENTYPE_KEYWORD_AS", 
								"TOKENTYPE_KEYWORD_PUBLIC", "TOKENTYPE_KEYWORD_PRIVATE", "TOKENTYPE_KEYWORD_IMPORT", "TOKENTYPE_FUNCTION",
								"TOKENTYPE_OPERATOR_OPENBRACKET", "TOKENTYPE_OPERATOR_CLOSEBRACKET", "TOKENTYPE_OPERATOR_OPENSQUAREBRACKET", 
								"TOKENTYPE_OPERATOR_CLOSESQUAREBRACKET", "TOKENTYPE_OPERATOR_OPENCURLYBRACE", "TOKENTYPE_OPERATOR_CLOSECURLYBRACE",
								"TOKENTYPE_OPERATOR_ADDITION", "TOKENTYPE_OPERATOR_SUBTRACTION", "TOKENTYPE_OPERATOR_MULTIPLACATION", "TOKENTYPE_OPERATOR_DIVISION", 
								"TOKENTYPE_OPERATOR_SEMICOLON", "TOKENTYPE_OPERATOR_DOTOPERATOR", "TOKENTYPE_OPERATOR_EQUALS", "TOKENTYPE_NUMBER", "TOKENTYPE_STRING", 
								"TOKENTYPE_IDENTIFIER", "TOKENTYPE_UNKOWN", "TOKENTYPE_FILE_EOF" };


struct TokenDebugInfo
{
	string File;
	size_t Line;
	size_t Column;

	TokenDebugInfo() {}

	TokenDebugInfo(string file, size_t line, size_t column) 
	{
		File = file;
		Line = line;
		Column = column;
	}
};

struct Token
{
	string TokenData;
	TokenType Type;
	TokenDebugInfo DebugInfo; 

	Token(string Data, TokenType TokType, TokenDebugInfo Debug)
	{
		TokenData = Data;
		Type = TokType;
		DebugInfo = Debug;
	}

	Token() {}

	void print(ostream& stream)
	{
		stream << "[Token Debug] " 
			<< "TokenType[\"" << TokenTypeNames[(int)Type] << "\"] "
			<< "TokenData[\"" << TokenData << "\"] " 
			<< "TokenDebugInfo:File[\"" << DebugInfo.File  << "\"] "
			<< "TokenDebugInfo:Line[\"" << DebugInfo.Line << "\"] "
			<< "TokenDebugInfo:Column[\"" << DebugInfo.Column << "\"] " << endl;
	}
};
