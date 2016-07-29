#include "Lexer.h"
#include "Token.h"

#include <fstream>
#include <cstdlib>

using namespace std;

int main(int argc, char** argv)
{
	Lexer Lex = Lexer("class;", "meme");
	Lex.Test();

	system("PAUSE");
	return 0;
}