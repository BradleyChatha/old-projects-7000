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

	Lexer Lex = Lexer("var MyPoint as Point = -10.4;", "meme");
	try
	{
		ASTNode_Variable var = ReadVariable(Lex);

		var.Name.print(cout);
		var.Value.Value.print(cout);
	}
	catch (exception& e) 
	{
		cout << e.what() << endl;
	}

		
	file.close();
	system("PAUSE");
	return 0;
}