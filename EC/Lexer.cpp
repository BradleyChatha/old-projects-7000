#include "Lexer.h"

#define GenerateSwitchCase(x, y) case ##x: return ##y


Lexer::Lexer(string Code, string File) : RawCode(Code), Index(0), Debug(File, 1, 1)
{
	PopFront();
}

Lexer::~Lexer()
{
}

void Lexer::Test(void)
{
	try
	{
		NextToken().print(cout);
	}
	catch(exception& e)
	{
		cout << e.what() << endl;
	}
}

void Lexer::PopFront(void)
{
	Front = NextToken();
}

Token Lexer::FrontToken(void)
{
	return Front;
}

bool Lexer::Empty(void)
{
	return (Front.Type == TokenType::TOKENTYPE_FILE_EOF);
}

Token Lexer::NextToken(void)
{
	SkipWhiteSpace();

	if (Index >= RawCode.length())
		return Token("", TokenType::TOKENTYPE_FILE_EOF, Debug);

	char c = NextCharacter(false);

	TokenType type = ToTokenType(string(1, c));

	if (type != TokenType::TOKENTYPE_UNKOWN
		&& !IsNumber(string(1, c))) // So, = works now, but you managed to break 
	{
		StepBack();
		return NextOperatorToken();
	}

	else if (IsNumber(string(1, c))) // This one
	{
		StepBack();
		return NextNumberToken();
	}
	else if (c == '"')
	{
		StepBack();
		return NextStringToken();
	}

	else
	{
		StepBack();
		return NextIdentifierToken();
	}
}

char Lexer::NextCharacter(bool escape)
{
	///Check if the file has reached the end or not.
	if (Index >= RawCode.length())
		throw runtime_error("Cannot read past the end of the file.");

	///The current character
	char c = RawCode[Index++];
	Debug.Column++;

	///Handle the escape characters
	if(escape && c == '\\')
	{
		switch (c)
		{
			GenerateSwitchCase('n', '\n');
			GenerateSwitchCase('t', '\t');
			GenerateSwitchCase('r', '\r');
			GenerateSwitchCase('\\', '\\');
			GenerateSwitchCase('"', '"');

		default:
			string errorMessage = "Unrecognised escaped character '";
			errorMessage += c;
			errorMessage += "'.";
			throw runtime_error(errorMessage);
			break;
		}
	}

	// Update the debug info
	if (c == '\n')
	{
		Debug.Column = 1;
		Debug.Line += 1;
	}

	return c;
}

Token Lexer::NextNumberToken(void)
{
	string Number = "";

	while (Index < RawCode.length())
	{
		auto c = NextCharacter(false);
		TokenType Type = ToTokenType(string(1, c));
		
		if (isspace(c) || Type != TokenType::TOKENTYPE_UNKOWN)
		{
			StepBack();
			break;
		}
		
		Number += c;
	}

	if (!IsNumber(Number))
		throw runtime_error("Incorrect function call. Given value is not a number.");

	return Token(Number, TokenType::TOKENTYPE_NUMBER, Debug);
}

Token Lexer::NextStringToken(void)
{
	SkipWhiteSpace();

	if (NextCharacter(false) != '"')
		throw runtime_error("Incorrect function call. Given value is not a string.");

	///The values have to be reset later in the function so we need to keep a copy of the old values alive.
	int OldIndex = Index;
	TokenDebugInfo OldDebug = Debug;
	Token StringToken = Token("", TokenType::TOKENTYPE_STRING, Debug);

	///Work out the length of the string.
	size_t StringSize = 0;
	while(true)
	{
		if (Index > RawCode.length())
			throw runtime_error("Unexpected EOF. String undetermined.");

		char c = NextCharacter(false);

		if (c == '"')
			break;

		else if (c == '\\')
		{
			StringSize++;
			NextCharacter(false);
		}
		else
			StringSize++;
	}

	Index = OldIndex;
	Debug = OldDebug;

	StringToken.TokenData.reserve(StringSize);

	for(int i = 0; i < StringSize; i++)
	{
		StringToken.TokenData += NextCharacter(false);
	}

	return StringToken;
}

Token Lexer::NextIdentifierToken(void)
{
	SkipWhiteSpace();
	string Text = "";
	int start = Index;

	///Work out the length of the identifier.
	while(true)
	{
		///EoF
		if (Index >= RawCode.length())
			break;

		char c = NextCharacter(false);

		if(isspace(c) || ToTokenType(string(1, c)) != TokenType::TOKENTYPE_UNKOWN)
		{
			StepBack();
			break;
		}
	}

	string TokenText = "";

	for (int i = start; i < Index; i++)
		TokenText += RawCode[i];

	TokenType Type = ToTokenType(TokenText);
	Type = ((Type == TokenType::TOKENTYPE_UNKOWN) ? TokenType::TOKENTYPE_IDENTIFIER : Type);
	
	return Token(TokenText, Type, Debug);
}

Token Lexer::NextOperatorToken(void)
{
	SkipWhiteSpace();
	Token OperatorToken = Token("", TokenType::TOKENTYPE_UNKOWN, Debug);
	char Operator = NextCharacter(false);
	TokenType Type = ToTokenType(string(1, Operator));
	
	if (Type == TokenType::TOKENTYPE_UNKOWN)
		throw runtime_error("Incorrect function call. Not an operator.");

	OperatorToken.TokenData = string(1, Operator);
	OperatorToken.Type = Type;

	return OperatorToken;
}

void Lexer::SkipWhiteSpace(void)
{
	while(true)
	{
		///Reached the end of the file? Well betterrrrrrr break or diva-sama shall smite me.
		if (Index >= RawCode.length())
			break;

		if(!isspace(NextCharacter(false)))
		{
			StepBack();
			break;
		}
	}

	///Skip over comments and then try to skip over whitespaces again.
	///Length - 2 in order to ensure that there is at least two characters to be read and doesn't through an
	///Out of Bounds exception like strings like to because they're rude.
	if(RawCode.length() >= 2 && Index <= RawCode.length() - 2)
	{
		if(NextCharacter(false) == '/')
		{
			if (NextCharacter(false) == '/')
			{
				while (true)
				{
					///Breaks if a new line is found or if the end of the code is reached which ever comes first.
					if (Index >= RawCode.length() || NextCharacter() == '\n')
						break;
				}

				SkipWhiteSpace();
			}
			else
			{
				StepBack();
				StepBack();
			}
		}
		else
		{
			StepBack();
		}
	}
}

void Lexer::StepBack(void)
{
	if (Index == 0)
		return;

	Index--;
	Debug.Column--;
}

TokenType Lexer::ToTokenType(string text)
{
	///String
	if(text.length() > 1)
	{
		GenerateIfCase(text, "namespace", TokenType::TOKENTYPE_KEYWORD_NAMESPACE);
		GenerateIfCase(text, "class", TokenType::TOKENTYPE_KEYWORD_CLASS);
		GenerateIfCase(text, "var", TokenType::TOKENTYPE_KEYWORD_VAR);
		GenerateIfCase(text, "if", TokenType::TOKENTYPE_KEYWORD_IF);
		GenerateIfCase(text, "elif", TokenType::TOKENTYPE_KEYWORD_ELIF);
		GenerateIfCase(text, "else", TokenType::TOKENTYPE_KEYWORD_ELSE);
		GenerateIfCase(text, "int", TokenType::TOKENTYPE_KEYWORD_INT);
		GenerateIfCase(text, "uint", TokenType::TOKENTYPE_KEYWORD_UINT);
		GenerateIfCase(text, "byte", TokenType::TOKENTYPE_KEYWORD_BYTE);
		GenerateIfCase(text, "ubyte", TokenType::TOKENTYPE_KEYWORD_UBYTE);
		GenerateIfCase(text, "float", TokenType::TOKENTYPE_KEYWORD_FLOAT);
		GenerateIfCase(text, "string", TokenType::TOKENTYPE_KEYWORD_STRING);
		GenerateIfCase(text, "return", TokenType::TOKENTYPE_KEYWORD_RETURN);
		GenerateIfCase(text, "for", TokenType::TOKENTYPE_KEYWORD_FOR);
		GenerateIfCase(text, "while", TokenType::TOKENTYPE_KEYWORD_WHILE);
		GenerateIfCase(text, "as", TokenType::TOKENTYPE_KEYWORD_AS);
		GenerateIfCase(text, "public", TokenType::TOKENTYPE_KEYWORD_PUBLIC);
		GenerateIfCase(text, "private", TokenType::TOKENTYPE_KEYWORD_PRIVATE);
		GenerateIfCase(text, "import", TokenType::TOKENTYPE_KEYWORD_IMPORT);
	}
	else ///Character
	{
		char value = text[0];
		
		GenerateIfCase(value, '.', TokenType::TOKENTYPE_OPERATOR_DOTOPERATOR);
		GenerateIfCase(value, ';', TokenType::TOKENTYPE_OPERATOR_SEMICOLON);
		GenerateIfCase(value, '/', TokenType::TOKENTYPE_OPERATOR_DIVISION);
		GenerateIfCase(value, '*', TokenType::TOKENTYPE_OPERATOR_MULTIPLACATION);
		GenerateIfCase(value, '+', TokenType::TOKENTYPE_OPERATOR_ADDITION);
		GenerateIfCase(value, '-', TokenType::TOKENTYPE_OPERATOR_SUBTRACTION);
		GenerateIfCase(value, '{', TokenType::TOKENTYPE_OPERATOR_OPENCURLYBRACE);
		GenerateIfCase(value, '}', TokenType::TOKENTYPE_OPERATOR_CLOSECURLYBRACE);
		GenerateIfCase(value, '(', TokenType::TOKENTYPE_OPERATOR_OPENBRACKET);
		GenerateIfCase(value, ')', TokenType::TOKENTYPE_OPERATOR_CLOSEBRACKET);
		GenerateIfCase(value, '[', TokenType::TOKENTYPE_OPERATOR_OPENSQUAREBRACKET);
		GenerateIfCase(value, ']', TokenType::TOKENTYPE_OPERATOR_CLOSESQUAREBRACKET);
		GenerateIfCase(value, '=', TokenType::TOKENTYPE_OPERATOR_EQUALS);
	}

	return TokenType::TOKENTYPE_UNKOWN;
}

bool Lexer::IsNumber(string num)
{
	return regex_match(num, regex("((\\+|-)?[[:digit:]]+)(\\.(([[:digit:]]+)?))?"));
}
