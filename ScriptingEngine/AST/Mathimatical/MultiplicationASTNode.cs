using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    public class MultiplicationASTNode : ASTNode
    {
        public MultiplicationASTNode(FloatTypeASTNode FloatNodeLeft, FloatTypeASTNode FloatNodeRight)
        {
            this.Left = FloatNodeLeft;
            this.Right = FloatNodeRight;
        }

        public MultiplicationASTNode(IntegerTypeASTNode IntNodeLeft, IntegerTypeASTNode IntNodeRight)
        {
            this.Left = IntNodeLeft;
            this.Right = IntNodeRight;
        }

        private ASTNode Left, Right;
    }
}
