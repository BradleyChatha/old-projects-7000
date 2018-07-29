using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    public class AdditionASTNode : ASTNode
    {
        public AdditionASTNode(FloatTypeASTNode FloatNodeLeft, FloatTypeASTNode FloatNodeRight)
        {
            this.Left = FloatNodeLeft;
            this.Right = FloatNodeRight;
        }

        public AdditionASTNode(IntegerTypeASTNode IntNodeLeft, IntegerTypeASTNode IntNodeRight)
        {
            this.Left = IntNodeLeft;
            this.Right = IntNodeRight;
        }

        private ASTNode Left, Right;
    }
}
