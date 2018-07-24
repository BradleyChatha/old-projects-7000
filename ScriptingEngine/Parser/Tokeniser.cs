using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.Parser
{
    public enum TokenType
    {
        Int,
        Float,
        String,
        Bool,
        Idenfitfier,
        Keyword,
        OpenBrackets,
        CloseBrackets,
        OpenBraces, //{
        CloseBraces, //}
        Colon,
        Assignment,
        Mathmatical,
        Accessor,
        Comma,
        BooleanOperator
    }

    public struct Token
    {
        public string Code;
        public TokenType Type;
    }

    public class Tokeniser
    {
        public Tokeniser(List<string> ParsedCode)
        {
            this.Code = ParsedCode;
        }

        public List<Token> Tokenise()
        {
            List<Token> Tokens = new List<Token>();

            for (int i = 0; i < Code.Count; i++)
            {
                string Current = Code[i];
                Token T;
                T.Code = Current;

                switch (Current)
                {
                    case "+":
                    case "-":
                    case "*":
                    case "/":
                        T.Type = TokenType.Mathmatical;
                        break;

                    case "==":
                    case "!=":
                    case "&&":
                    case "!":
                    case "<":
                    case "<=":
                    case ">":
                    case ">=":
                        T.Type = TokenType.BooleanOperator;
                        break;

                    case ".":
                        T.Type = TokenType.Accessor;
                        break;

                    case ",":
                        T.Type = TokenType.Comma;
                        break;

                    case "(":
                        T.Type = TokenType.OpenBrackets;
                        break;
                    case ")":
                        T.Type = TokenType.CloseBrackets;
                        break;

                    case "{":
                        T.Type = TokenType.OpenBraces;
                        break;
                    case "}":
                        T.Type = TokenType.CloseBraces;
                        break;

                    case "=":
                    case "+=":
                    case "-=":
                    case "*=":
                    case "/=":
                        T.Type = TokenType.Assignment;
                        break;

                    case ":":
                        T.Type = TokenType.Colon;
                        break;

                    case "function":
                    case "int":
                    case "string":
                    case "float":
                    case "bool":
                    case "if":
                    case "for":
                    case "while":
                    case "continue":
                    case "break":
                    case "var":
                        T.Type = TokenType.Keyword;
                        break;

                    case "true":
                    case "false":
                        T.Type = TokenType.Bool;
                        break;

                    default:
                        ///Numbers and strings in here too.
                        
                        ///Don't want the value as an integer, just want to ensure it is an int.
                        if(int.TryParse(Current, out int ThrowAway))
                        {
                            T.Type = TokenType.Int;
                            break;
                        }
                        else if(float.TryParse(Current, out float Throw))
                        {
                            T.Type = TokenType.Float;
                            break;
                        }
                        
                        if(Current[0] == '"')
                        {
                            if(Current[Current.Length - 1] == '"')
                            {
                                T.Type = TokenType.String;
                                break;
                            }
                            else
                            {
                                ///Throw an error.
                            }
                        }

                        T.Type = TokenType.Idenfitfier;
                        break;
                }

                Tokens.Add(T);
            }

            return Tokens;
        }

        private List<string> Code;
    }
}
