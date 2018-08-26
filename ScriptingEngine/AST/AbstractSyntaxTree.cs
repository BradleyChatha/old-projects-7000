using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ScriptingEngine.Parser;

namespace ScriptingEngine.AST
{
    public class AbstractSyntaxTree
    {
        public AbstractSyntaxTree(List<Token> Tokens)
        {
            ASTScopeIdentifierGenerator.InitIdentifier();
            this.Tokens = Tokens;
            this.GlobalScope = new ASTScope(ASTScopeIdentifierGenerator.GenerateNextID()); ///Global scope ID should always be 0
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
                    if((i - 1) < 0 || (i + 1) > TokenCount - 1)
                    { 
                        this.ErrorHandler.PushNewError("Incomplete maths statment");
                        break;
                    }

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
                else if(Current.Type == TokenType.OpenBraces)
                {
                    this.CurrentScope.AddASTNode(this.ConstructASTScopeID());
                    ASTScope TempScope = this.ConstructNewScope(this.CurrentScope);
                    this.CurrentScope = TempScope;
                }
                else if(Current.Type == TokenType.CloseBraces)
                {
                    if(this.CurrentScope == this.GlobalScope)
                    {
                        this.ErrorHandler.PushNewError("Unexpected closing brace");
                        break;
                    }

                    ASTScope Child = this.CurrentScope;
                    this.CurrentScope = this.CurrentScope.Parent;
                    this.CurrentScope.AddChildScope(Child);
                }
                else if(Current.Type == TokenType.Keyword)
                {
                    if(Current.Code == "var")
                    {
                        bool HasError = false;

                        ///var : int myint = 10
                        if(i + 3 > TokenCount)
                        {
                            this.ErrorHandler.PushNewError("Incomplete variable declaration");
                            break;
                        }

                        if (this.Tokens[i + 1].Type == TokenType.Colon)
                        {
                            i += 2;

                            if(this.Tokens[i].Type == TokenType.Keyword)
                            {
                                switch(Tokens[i].Code)
                                { 
                                    case "int":
                                        i += 1;
                                        Token Ident = Tokens[i];

                                        if(i + 2 < TokenCount && this.Tokens[i + 1].Type == TokenType.Assignment)
                                        {
                                            ///It has an assignment
                                            if(this.Tokens[i + 2].Type == TokenType.Int)
                                            {
                                                i += 2;
                                                this.CurrentScope.AddASTNode(this.ConstructIntASTNode(Ident, this.Tokens[i]));
                                            }
                                            else
                                            {
                                                HasError = true;
                                                this.ErrorHandler.PushNewError("Missing assignment operator");
                                            }
                                        }
                                        else
                                            this.CurrentScope.AddASTNode(this.ConstructIntASTNode(Ident));
                                        break;
                                }

                                if(HasError)
                                    break;
                            }
                        }
                        else
                        {
                            this.ErrorHandler.PushNewError("Missing colon");
                            break;
                        }
                    }
                }
            }

            this.ErrorHandler.PrintAllErrors();
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

        private ASTScope ConstructNewScope(ASTScope ParentScope)
        {
            return new ASTScope(ASTScopeIdentifierGenerator.GetCurrentID(), ParentScope);
        }

        private IntASTNode ConstructIntASTNode(Token Identifier)
        {
            return new IntASTNode(new IdentifierASTNode(Identifier));
        }

        private IntASTNode ConstructIntASTNode(Token Identifier, Token Value)
        {
            return new IntASTNode(new IdentifierASTNode(Identifier), new IntegerTypeASTNode(Value));
        }

        private ASTScopeIdentifier ConstructASTScopeID()
        {
            return new ASTScopeIdentifier(ASTScopeIdentifierGenerator.GenerateNextID());
        }

        private List<Token> Tokens;
        private ASTScope GlobalScope;
        private ASTScope CurrentScope;
        private Error ErrorHandler;
    }
}
