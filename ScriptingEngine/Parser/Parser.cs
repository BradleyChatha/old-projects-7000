using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine.Parser
{
    public class Parser
    {
        public List<string> Parse(string Raw)
        {
            List<string> ParsedCode = new List<string>();
            int RawLength = Raw.Length;
            string CurrentString = "";
            bool IsInString = false;
            bool IsHandlingSpecial = false;
            bool IsInNumber = false;
            char PreviousChar = ' ';

            char[] SpecialChars = { '=', '!', '+', '-', '*', '/', '<', '>', '|', '.', '&', ',' };

            for(int i = 0; i < RawLength; i++)
            {
                char Current = Raw[i];

                if(Current  == '"' && PreviousChar != '\\')
                {
                    if (IsInString)
                    {
                        CurrentString += Current;
                        ParsedCode.Add(CurrentString);
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

                if(int.TryParse(Current.ToString(), out int Result) && !IsInNumber)
                {
                    IsInNumber = true;
                    CurrentString += Current;
                    continue;
                }

                if(IsInNumber)
                {
                    if(!int.TryParse(Current.ToString(), out int A) && Current != '.')
                    {
                        IsInNumber = false;
                        ParsedCode.Add(CurrentString);
                        CurrentString = "";
                        CurrentString += Current;
                        continue;
                    }

                    CurrentString += Current;
                    continue;
                }

                if (SpecialChars.Contains(Current))
                {
                    if(!IsHandlingSpecial)
                    {
                        ParsedCode.Add(CurrentString);
                        CurrentString = "";
                        IsHandlingSpecial = true;
                        CurrentString += Current;
                        continue;
                    }
                }
                else if(IsHandlingSpecial)
                {
                    ParsedCode.Add(CurrentString);
                    CurrentString = "";
                    IsHandlingSpecial = false;
                    continue;
                }

                if (Current == ' ' && CurrentString != "")
                {
                    ParsedCode.Add(CurrentString);
                    CurrentString = "";
                    continue;
                }

                CurrentString += Current;
                PreviousChar = Current;
            }

            if(CurrentString != "")
                ParsedCode.Add(CurrentString);

            for (int i = 0; i < ParsedCode.Count; i++)
            {
                if(ParsedCode[i] == "" || string.IsNullOrWhiteSpace(ParsedCode[i]))
                    ParsedCode.RemoveAt(i);
            }

            return ParsedCode;
        }
    }
}
