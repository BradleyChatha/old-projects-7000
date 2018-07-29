using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST
{
    public class ASTNode
    {
        public ASTNode()
        {

        }

        public Token Tok
        {
            get;
            protected set;
        }
    }
}
