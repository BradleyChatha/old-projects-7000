using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    public class DivisionASTNode : ASTNode
    {
        public DivisionASTNode(FloatTypeASTNode FloatNodeLeft, FloatTypeASTNode FloatNodeRight)
        {
            this.Left = FloatNodeLeft;
            this.Right = FloatNodeRight;
        }

        public DivisionASTNode(IntegerTypeASTNode IntNodeLeft, IntegerTypeASTNode IntNodeRight)
        {
            this.Left = IntNodeLeft;
            this.Right = IntNodeRight;
        }

        private ASTNode Left, Right;
    }
}
