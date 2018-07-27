using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST
{
    class BaseASTNode
    {
        public BaseASTNode()
        {

        }

        public Token Tok
        {
            get;
            protected set;
        }
    }
}
