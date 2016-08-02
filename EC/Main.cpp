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

	Lexer Lex = Lexer("var MyString as string = \"Hello World\";", "meme");
	try
	{
		ASTNode_Variable var = ReadVariable(Lex);

		var.Name.print(cout);
		var.Value.Value.print(cout);
		cout << (int)var.Value.Type << endl;
	}
	catch (exception& e) 
	{
		cout << e.what() << endl;
	}

		
	file.close();
	system("PAUSE");
	return 0;
}