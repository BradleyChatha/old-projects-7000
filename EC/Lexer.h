#pragma once

#include <string>
#include <iostream>
#include <deque>
#include <vector>
#include <regex>
#include <stdexcept>
#include <typeinfo>
#include "Token.h"
#include "TokenType.h"

using namespace std;

///Checks the if the data type of 'x' matches with data type of 'z'
#define CheckType(x, y) typeid(x) == typeid(y)

///Compares 'x' and 'y' and returns 'z' if true.
#define GenerateIfCase(x, y, z) if(x == y) return z

///The lexer for the language. It will turn the given code in to tokens.
class Lexer
{
public:
	Lexer(string Code, string File);
	~Lexer();

	///Temporary Function to test the lexer is working.
	void Test(void);

private:
	///The raw code.
	string RawCode;
	///The index in the current code.
	unsigned int Index;
	///The last token which was parsed.
	Token Front;
	///For debugging the program.
	TokenDebugInfo Debug;

	///Returns the next token in the squence.
	Token NextToken(void);

	///Returns the next character
	char NextCharacter(bool escape = false);

	///Returns the next token which is a number
	Token NextNumberToken(void);

	///Returns the next token which is a string
	Token NextStringToken(void);

	///Returns the next identifier token
	void NextIdentifierToken(void);

	///Skips over all the whitespaces
	void SkipWhiteSpace(void);

	///Decrements the index by one.
	void StepBack(void);

	///Works out the token type
	template<class T>
	TokenType ToTokenType(T text)
	{
		if(CheckType(T, string))
		{
			GenerateIfCase(text, "namespace", TokenType::TOKENTYPE_KEYWORD_NAMESPACE);
			GenerateIfCase(text, "class", TokenType::TOKENTYPE_KEYWORD_CLASS);
			GenerateIfCase(text, "var", TokenType::TOKENTYPE_KEYWORD_VAR);
			GenerateIfCase(text, "if", TokenType::TOKENTYPE_KEYWORD_IF);
			GenerateIfCase(text, "elif", TokenType::TOKENTYPE_KEYWORD_ELIF);
			GenerateIfCase(text, "else", TokenType::TOKENTYPE_KEYWORD_ELSE);

		}
		else if(CheckType(T, char))
		{

		}
		else
		{
			throw invalid_argument("T is of an unkown type and is not textual.");
		}

		return TokenType::TOKENTYPE_UNKOWN;
	}
};

