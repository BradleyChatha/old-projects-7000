using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    class IntASTNode : ASTNode
    {
        public IntASTNode(IdentifierASTNode IdentifierNode, IntegerTypeASTNode ValueNode)
        {
            this.Identifier = IdentifierNode;
            this.Value = ValueNode;
        }

        public IntASTNode(IdentifierASTNode IdentifierNode)
        {
            this.Identifier = IdentifierNode;

            Parser.Token Tok = new Parser.Token();
            Tok.Code = "0";
            Tok.Type = Parser.TokenType.Int;
            this.Value = new IntegerTypeASTNode(Tok);
        }

        public IdentifierASTNode Identifier
        {
            get;
            private set;
        }

        public IntegerTypeASTNode Value
        {
            get;
            private set;
        }
    }
}
