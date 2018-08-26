using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.Parser
{
    public class Parser
    {
        public Parser()
        { }

        public List<string> Parse(string Raw)
        {
            List<string> ParsedCode = new List<string>();
            int RawLength = Raw.Length;
            string CurrentString = "";
            bool IsInString = false;
            bool IsHandlingSpecial = false;
            bool IsInNumber = false;
            char PreviousChar = ' ';

            char[] SpecialChars = { '!', '+', '-', '*', '/', '.', ',', '{', '}', '(', ')' }; ///Single chars
            char[] MultiCharOps = { '=', '<', '>', '|', '&' }; // For handling things like ==

            void PushCode()
            {
                if(CurrentString != "")
                    ParsedCode.Add(CurrentString);
            }

            for (int i = 0; i < RawLength; i++)
            {
                char Current = Raw[i];

                if (!IsInString && (Current == ' ' || Current == '\t' || Current == '\r' || Current == '\n'))
                {
                    PushCode();
                    CurrentString = "";
                    IsInNumber = false;
                    continue;
                }

                if(Current  == '"' && PreviousChar != '\\')
                {
                    if (IsInString)
                    {
                        CurrentString += Current;
                        PushCode();
                        CurrentString = "";
                        IsInString = false;
                        continue;
                    }
                    else
                    {
                        CurrentString += Current;
                        IsInString = true;
                        continue;
                    }
                }

                if (IsInString)
                {
                    CurrentString += Current;
                    continue;
                }

                if ((SpecialChars.Contains(Current) || MultiCharOps.Contains(Current)) && !IsInString && ParsedCode.Count > 0 && (ParsedCode[ParsedCode.Count - 1][0] != '=' && !int.TryParse(ParsedCode[ParsedCode.Count - 1], out int _)))
                {
                    PushCode();
                    CurrentString = "";
                    CurrentString += Current;

                    if (MultiCharOps.Contains(Current) && !IsHandlingSpecial)
                        IsHandlingSpecial = true;
                    else
                    {
                        PushCode();
                        CurrentString = "";
                    }

                    continue;
                }
                else if (IsHandlingSpecial && !IsInString)
                {
                    PushCode();
                    CurrentString = "";
                    IsHandlingSpecial = false;
                }

                if (int.TryParse(Current.ToString(), out int Result1) && !IsInNumber)
                {
                    IsInNumber = true;
                    CurrentString += Current;
                    continue;
                }
                else if(Current == '-' && (Current + 1) < RawLength && int.TryParse(Raw[Current + 1].ToString(), out int Result2) && !IsInNumber)
                {
                    IsInNumber = true;
                    CurrentString += Current;
                    continue;
                }

                if(IsInNumber)
                {
                    if(!int.TryParse(Current.ToString(), out int Result3) && Current != '.')
                    {
                        IsInNumber = false;
                        PushCode();
                        CurrentString = "";
                        CurrentString += Current;
                        continue;
                    }

                    CurrentString += Current;
                    continue;
                }

                if (Current == ' ' && CurrentString != "")
                {
                    PushCode();
                    CurrentString = "";
                    continue;
                }

                CurrentString += Current;
                PreviousChar = Current;
            }

            PushCode();

            return ParsedCode;
        }
    }
}
