using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST
{
    public class StringTypeASTNode : ASTNode
    {
        public StringTypeASTNode(Token Tok)
        {
            this.Tok = Tok;
        }
    }

    public class FloatTypeASTNode : ASTNode
    {
        public FloatTypeASTNode(Token Tok)
        {
            this.Tok = Tok;
        }
    }

    public class IntegerTypeASTNode : ASTNode
    {
        public IntegerTypeASTNode(Token Tok)
        {
            this.Tok = Tok;
        }
    }

    public class BoolTypeASTNode : ASTNode
    {
        public BoolTypeASTNode(Token Tok)
        {
            this.Tok = Tok;
        }
    }
}
