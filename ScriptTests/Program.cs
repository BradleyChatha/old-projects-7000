using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.AST;
using ScriptingEngine.Parser;

namespace ScriptTests
{
    class Program
    {
        static void Main(string[] args)
        {
            Parser P = new Parser();
            var pc = P.Parse("var : int MyInt {var : int Doot = 10}");
            Tokeniser Tok = new Tokeniser(pc);
            var tc = Tok.Tokenise();
            AbstractSyntaxTree Tree = new AbstractSyntaxTree(tc);
            Tree.ConstructTree();

            var s = Tree.GetCurrent();

            Console.ReadLine();
        }
    }
}
