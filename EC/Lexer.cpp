#include "Lexer.h"

#define GenerateSwitchCase(x, y) case ##x: return ##y


Lexer::Lexer(string Code, string File) : RawCode(Code), Index(0), Debug(File, 1, 1)
{
}

Lexer::~Lexer()
{
}

void Lexer::Test(void)
{
	try
	{
		cout << TokenTypeNames[(int)ToTokenType<string>("else")] << endl;
	}
	catch(exception& e)
	{
		cout << e.what() << endl;
	}
}

Token Lexer::NextToken(void)
{
	return Token("MeMe", TokenType::TOKENTYPE_FILE_EOF, Debug);
}

char Lexer::NextCharacter(bool escape)
{
	///Check if the file has reached the end or not.
	if (Index >= RawCode.length())
		throw runtime_error("Cannot read past the end of the file.");

	///The current character
	char c = RawCode[Index++];

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
		if (isspace(c))
			break;
		Number += c;
	}

	if (!regex_match(Number, regex("((\\+|-)?[[:digit:]]+)(\\.(([[:digit:]]+)?))?")))
		throw runtime_error("Incorrect funcation call. Given value is not a number.");

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

void Lexer::NextIdentifierToken(void)
{
	SkipWhiteSpace();
	string Text = "";
	int start = Index;

	/*//Work out the length of the identifier.
	while(true)
	{
		///EoF
		if (Index >= RawCode.length())
			break;


	}*/
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
	if(Index <= RawCode.length() - 2)
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
