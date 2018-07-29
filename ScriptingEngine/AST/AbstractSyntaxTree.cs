using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

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

        List<ASTNode> Nodes;
        List<ASTScope> ChildScopes;
        ASTScope Parent;
    }

    public class AbstractSyntaxTree
    {
        public AbstractSyntaxTree(List<Token> Tokens)
        {
            this.Tokens = Tokens;
            this.GlobalScope = new ASTScope();
            this.CurrentScope = GlobalScope;
            this.ErrorHandler = new Error();
        }

        public void ConstructTree()
        {
            int TokenCount = Tokens.Count;
            
            for (int i = 0; i < TokenCount; i++)
            {
                Token Current = Tokens[i];

                if(Current.Type == TokenType.Mathmatical)
                {
                    if((i - 1) > 0 || (i + 1) < TokenCount)
                        this.ErrorHandler.PushNewError("Incomplete addition statment");

                    switch(Current.Code)
                    {
                        case "+":
                            this.CurrentScope.AddASTNode(this.ConstructAdditionStatement(Tokens[i - 1], Tokens[i + 1]));
                            break;

                        case "-":
                            this.CurrentScope.AddASTNode(this.ConstructSubtractionStatement(Tokens[i - 1], Tokens[i + 1]));
                            break;

                        case "*":
                            this.CurrentScope.AddASTNode(this.ConstructMultiplactionStatement(Tokens[i - 1], Tokens[i + 1]));
                            break;

                        case "/":
                            this.CurrentScope.AddASTNode(this.ConstructDivisionStatement(Tokens[i - 1], Tokens[i + 1]));
                            break;
                    }
                    
                }
            }
        }

        public ASTScope GetCurrent()
        {
            return CurrentScope;
        }

        private AdditionASTNode ConstructAdditionStatement(Token Left, Token Right)
        {
            ///If either LHS or RHS are float, convert both values to a float.
            if(Left.Type == TokenType.Float || Right.Type == TokenType.Float)
            {
                ///Just in case something else throws up a stink later in the program
                Left.Type = TokenType.Float;
                Right.Type = TokenType.Float;

                FloatTypeASTNode LeftFloatNode = new FloatTypeASTNode(Left);
                FloatTypeASTNode RightFloatNode = new FloatTypeASTNode(Right);
                
                return new AdditionASTNode(LeftFloatNode, RightFloatNode);
            }

            IntegerTypeASTNode LeftNode = new IntegerTypeASTNode(Left);
            IntegerTypeASTNode RightNode = new IntegerTypeASTNode(Right);

            return new AdditionASTNode(LeftNode, RightNode);
        }

        private SubtractionASTNode ConstructSubtractionStatement(Token Left, Token Right)
        {
            ///If either LHS or RHS are float, convert both values to a float.
            if (Left.Type == TokenType.Float || Right.Type == TokenType.Float)
            {
                ///Just in case something else throws up a stink later in the program
                Left.Type = TokenType.Float;
                Right.Type = TokenType.Float;

                FloatTypeASTNode LeftFloatNode = new FloatTypeASTNode(Left);
                FloatTypeASTNode RightFloatNode = new FloatTypeASTNode(Right);

                return new SubtractionASTNode(LeftFloatNode, RightFloatNode);
            }

            IntegerTypeASTNode LeftNode = new IntegerTypeASTNode(Left);
            IntegerTypeASTNode RightNode = new IntegerTypeASTNode(Right);

            return new SubtractionASTNode(LeftNode, RightNode);
        }

        private MultiplicationASTNode ConstructMultiplactionStatement(Token Left, Token Right)
        {
            ///If either LHS or RHS are float, convert both values to a float.
            if (Left.Type == TokenType.Float || Right.Type == TokenType.Float)
            {
                ///Just in case something else throws up a stink later in the program
                Left.Type = TokenType.Float;
                Right.Type = TokenType.Float;

                FloatTypeASTNode LeftFloatNode = new FloatTypeASTNode(Left);
                FloatTypeASTNode RightFloatNode = new FloatTypeASTNode(Right);

                return new MultiplicationASTNode(LeftFloatNode, RightFloatNode);
            }

            IntegerTypeASTNode LeftNode = new IntegerTypeASTNode(Left);
            IntegerTypeASTNode RightNode = new IntegerTypeASTNode(Right);

            return new MultiplicationASTNode(LeftNode, RightNode);
        }

        private DivisionASTNode ConstructDivisionStatement(Token Left, Token Right)
        {
            ///If either LHS or RHS are float, convert both values to a float.
            if (Left.Type == TokenType.Float || Right.Type == TokenType.Float)
            {
                ///Just in case something else throws up a stink later in the program
                Left.Type = TokenType.Float;
                Right.Type = TokenType.Float;

                FloatTypeASTNode LeftFloatNode = new FloatTypeASTNode(Left);
                FloatTypeASTNode RightFloatNode = new FloatTypeASTNode(Right);

                return new DivisionASTNode(LeftFloatNode, RightFloatNode);
            }

            IntegerTypeASTNode LeftNode = new IntegerTypeASTNode(Left);
            IntegerTypeASTNode RightNode = new IntegerTypeASTNode(Right);

            return new DivisionASTNode(LeftNode, RightNode);
        }

        private List<Token> Tokens;
        private ASTScope GlobalScope;
        private ASTScope CurrentScope;
        private Error ErrorHandler;
    }
}
