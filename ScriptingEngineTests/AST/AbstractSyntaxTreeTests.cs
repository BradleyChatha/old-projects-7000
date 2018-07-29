using Microsoft.VisualStudio.TestTools.UnitTesting;
using ScriptingEngine.AST;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST.Tests
{
    [TestClass()]
    public class AbstractSyntaxTreeTests
    {
        [TestMethod()]
        public void ConstructTreeTest()
        {
            Parser.Parser P = new Parser.Parser();
            var PCode = P.Parse("1.0 + 2.0 - 1 * 9 / 8");
            Tokeniser Tok = new Tokeniser(PCode);
            var TCode = Tok.Tokenise();

            AbstractSyntaxTree AST = new AbstractSyntaxTree(TCode);
            AST.ConstructTree();
            var ASTS = AST.GetCurrent();
            
            Console.WriteLine();
        }
    }
}