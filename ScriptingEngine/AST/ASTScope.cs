using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.AST
{
    public class ASTScopeIdentifierGenerator
    {
        public static void InitIdentifier()
        {
            IDCounter = -1;
        }

        public static int GetCurrentID()
        {
            return IDCounter;
        }

        public static int GenerateNextID()
        {
            IDCounter += 1;
            return IDCounter;
        }

        public static int IDCounter;
    }

    public class ASTScopeIdentifier : ASTNode
    {
        public ASTScopeIdentifier(int Owner)
        {
            this.OwnerID = Owner;
        }

        public int OwnerID;
    }

    public class ASTScope
    {
        public ASTScope(int ID, ASTScope Parent = null)
        {
            this.Parent = Parent;
            this.Nodes = new List<ASTNode>();
            this.ChildScopes = new List<ASTScope>();
            this.ScopeID = ID;
        }

        public void AddASTNode(ASTNode Node)
        {
            this.Nodes.Add(Node);
        }

        public void AddChildScope(ASTScope ChildScope)
        {
            this.ChildScopes.Add(ChildScope);
        }

        public int ScopeID;
        public ASTScope Parent;

        private List<ASTNode> Nodes;
        private List<ASTScope> ChildScopes;
    }
}
