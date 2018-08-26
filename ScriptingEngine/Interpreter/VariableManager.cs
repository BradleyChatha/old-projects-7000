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
        enum VariableType
        {
            Int = 0,
            Float,
            String,
            Bool
        }

        struct VariableDescriptor
        {
            public VariableType Type;
            public string ID;
        }

        public VariableManager()
        {
            this.Variables = new Dictionary<VariableDescriptor, ASTNode>();
            this.ErrorHandler = new Error();
        }

        public void AddNewVariable(IntASTNode Variable)
        {
            VariableDescriptor Descriptor;
            Descriptor.Type = VariableType.Int;
            Descriptor.ID = Variable.Identifier.Tok.Code;
        }

        public IntASTNode GetIntVariable(IdentifierASTNode Identifier)
        {
            VariableDescriptor Descriptor;
            Descriptor.Type = VariableType.Int;
            Descriptor.ID = Identifier.Tok.Code;

            if (!this.Variables.ContainsKey(Descriptor))
            {
                this.ErrorHandler.PushNewError($"Unkown identifier '{Descriptor.ID}'");
                this.ErrorHandler.PrintAllErrors();
            }

            return this.Variables[Descriptor] as IntASTNode;
        }

        private Dictionary<VariableDescriptor, ASTNode> Variables; ///VariableDescriptor = identifier, ASTNode = value
        private Error ErrorHandler;
    }
}
