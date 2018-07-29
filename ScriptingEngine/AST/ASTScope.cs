using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    public class ASTScope
    {
        public ASTScope(ASTScope Parent = null)
        {
            this.Parent = Parent;
            this.Nodes = new List<ASTNode>();
            this.ChildScopes = new List<ASTScope>();
        }

        public void AddASTNode(ASTNode Node)
        {
            this.Nodes.Add(Node);
        }

        public void AddChildScope(ASTScope ChildScope)
        {
            this.ChildScopes.Add(ChildScope);
        }

        public ASTScope Parent;

        private List<ASTNode> Nodes;
        private List<ASTScope> ChildScopes;
    }
}
