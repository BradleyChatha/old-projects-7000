#include "Lexer.h"
#include "Token.h"

#include <fstream>
#include <vector>
#include <algorithm>
#include <cstdlib>

using namespace std;

int main(int argc, char** argv)
{
	ofstream file("Tokens.txt");

	Lexer Lex = Lexer("var MyInt as int = 10;", "meme");
	try
	{
		while (!Lex.Empty())
		{
			Lex.FrontToken().print(cout);
			Lex.FrontToken().print(file);

			cout << Lex.FrontToken().IsAnyOf({ TokenType::TOKENTYPE_KEYWORD_INT, TokenType::TOKENTYPE_KEYWORD_AS }) << endl;

			Lex.PopFront();
		}

		Lex.FrontToken().print(cout);
		Lex.FrontToken().print(file);
	}
	catch (exception& e) 
	{
		cout << e.what() << endl;
	}

		
	file.close();
	system("PAUSE");
	return 0;
}