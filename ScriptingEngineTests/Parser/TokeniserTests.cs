using Microsoft.VisualStudio.TestTools.UnitTesting;
using ScriptingEngine.Parser;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.Parser.Tests
{
    [TestClass()]
    public class TokeniserTests
    {
        [TestMethod()]
        public void TokeniseTest()
        {
            Parser P = new Parser();
            var l = P.Parse("1.3 2 Hello World, != 123 \"dsdsds\" int bool 2.3 100 bool int \"asa\" <= > = ident + * / - && &");
            Tokeniser T = new Tokeniser(l);
            
            var a = T.Tokenise();
        }
    }
}