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

                if(Current == 'i')
                    Console.WriteLine();

                if(!IsInString && (Current == ' ' || Current == '\t' || Current == '\r' || Current == '\n'))
                {
                    ParsedCode.Add(CurrentString);
                    CurrentString = "";
                    IsInNumber = false;
                    continue;
                }

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

                if(int.TryParse(Current.ToString(), out int Result1) && !IsInNumber)
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
                    CurrentString = "";
                    CurrentString += Current;
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

            ///Danhack
            for (int i = 0; i < ParsedCode.Count; i++)
            {
                if(ParsedCode[i] == "")
                { 
                    ParsedCode.RemoveAt(i);
                    i--;
                }
            }

            return ParsedCode;
        }
    }
}
