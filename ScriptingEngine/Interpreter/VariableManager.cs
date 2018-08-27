using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using ScriptingEngine.AST;
using ScriptingEngine.Parser;

namespace ScriptingEngine.Interpreter
{
    class VariableManager
    {
        public VariableManager()
        {
            this.Variables = new Dictionary<Token, ASTNode>();
            this.ErrorHandler = new Error();
        }

        public void AddNewVariable(IntASTNode Variable)
        {
            this.Variables.Add(Variable.Identifier.Tok, Variable);
        }

        public IntASTNode GetIntVariable(IdentifierASTNode Identifier)
        {
            if (!this.Variables.ContainsKey(Identifier.Tok))
            {
                this.ErrorHandler.PushNewError($"Unkown identifier '{Identifier.Tok.Code}'");
                this.ErrorHandler.PrintAllErrors();
            }

            return this.Variables[Identifier.Tok] as IntASTNode;
        }

        private Dictionary<Token, ASTNode> Variables; ///Token = identifier, ASTNode = value
        private Error ErrorHandler;
    }
}
