#include "Lexer.h"
#include "Token.h"
#include "ASTNodes.h"

#include <fstream>
#include <vector>
#include <algorithm>
#include <cstdlib>

using namespace std;

int main(int argc, char** argv)
{
	ofstream file("Tokens.txt");

	Lexer Lex = Lexer("Print(var Str as string, var length as int) as void", "meme");
	try
	{
		ASTNode_Function func = ReadDefineFunction(Lex);


	}
	catch (exception& e) 
	{
		cout << e.what() << endl;
	}

		
	file.close();
	system("PAUSE");
	return 0;
}