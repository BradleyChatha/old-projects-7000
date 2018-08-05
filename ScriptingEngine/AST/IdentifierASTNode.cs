using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST
{
    class IdentifierASTNode : ASTNode
    {
        public IdentifierASTNode(Token Tok)
        {
            this.Tok = Tok;
        }
    }
}
