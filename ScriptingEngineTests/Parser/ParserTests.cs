using Microsoft.VisualStudio.TestTools.UnitTesting;
using ScriptingEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.Parser.Tests
{
    [TestClass()]
    public class ParserTests
    {
        [TestMethod()]
        public void ParseTest()
        {
            Parser P = new Parser();
            var a = P.Parse("Hello World, != 123 \"dsdsds\"");

            ///Should be [Hello, World, ',', !=, 123, "dsdsds", "\""]
            List<string> Target = new List<string>();
            Target.Add("Hello");
            Target.Add("World");
            Target.Add(",");
            Target.Add("!=");
            Target.Add("123");
            Target.Add("\"dsdsds\"");

            for (int i = 0; i < Target.Count; i++)
            {
                if(a[i] != Target[i])
                    Assert.Fail();
            }
        }
    }
}