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

	Lexer Lex = Lexer("namespace MyModule;", "meme");
	try
	{
		ASTNode_Namespace name = ReadNamespace(Lex);

		name.Namespace.print(cout);
		name.Name.Value.print(cout);
	}
	catch (exception& e) 
	{
		cout << e.what() << endl;
	}

		
	file.close();
	system("PAUSE");
	return 0;
}