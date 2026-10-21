using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;

namespace SoupScript_CSharp
{
    class Program
    {
        /// <summary>
        /// Stores what line we're at in the file
        /// </summary>
        static int Line = 0;

        /// <summary>
        /// Dictionary (map in C++) to store the variables
        /// </summary>
        static Dictionary<String, String> Variables = new Dictionary<String, String>();

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="args">Blehg</param>
        static void Main(string[] args)
        {
            // Tell the program we're on our first loop
            bool First = false;

            // Loop
            while (true)
            {
                // If this isn't the first loop
                if (First)
                {
                    // Write the endy stuff
                    Console.WriteLine("Press any key to continue...");
                    Console.ReadKey();
                }

                // Clear the console
                Console.Clear();

                // "Enter command", Then check what do do based on the command given
                Console.Write("Enter command: ");
                Command(Console.ReadLine());

                // Tell the program we're not on our first loop
                First = true;
            }
        }

        /// <summary>
        /// Executes X depending on what "com" is
        /// </summary>
        /// <param name="com">Command to check</param>
        static void Command(String com)
        {
            // Check "com" to the cases, in Lower-case form
            switch (com.ToLower())
            {
                // Exit the program
                case "exit":
                case "stop":
                case "logout":
                    Environment.Exit(0);
                    break;

                    // Get the filepath, then "compile" it
                case "compile":
                    Console.Write("Enter file: ");
                    Compile(Console.ReadLine());
                    break;
            }
        }

        /// <summary>
        /// Checks to see if Variables contains "key", if not, then return the "key" given(As that will be the value)
        /// </summary>
        /// <param name="key">Key to check for</param>
        /// <returns>Either the Value from Variables[key] or just key Itself</returns>
        static String GetVar(String key)
        {
            // If Variables has what we're looking for, return it's value
            if (Variables.ContainsKey(key))
            {
                return Variables[key];
            }

            // If not, return the key which will be the value
            else
            {
                return key;
            }
        }

        /// <summary>
        /// "Compiles" the script
        /// </summary>
        /// <param name="file">Script to "Compile"</param>
        static void Compile(String file)
        {
            // Formatting
            Console.WriteLine();

            // Check that the file exists
            if (!File.Exists(file))
            {
                Console.WriteLine("\nERROR: File not found!\n");
                return;
            }

            // Read the file into memory
            String[] Contents = File.ReadAllLines(file);

            // Flag saying whether to run commands or not
            bool IfCondition = true;

            // Loop through the File's contents
            for (int i = 0; i < Contents.Length; i++)
            {
                // Get the current line
                String s = Contents[i];

                // If it's an if
                if (s.StartsWith("if"))
                {
                    // Split it into Data
                    // Data =
                    // "if" Value1 [Operator] Value2
                    String[] Data = s.Split(" ".ToCharArray(), 4);

                    // If [Operator] is ==, check if Value1 == Value2
                    if (Data[2].Equals("=="))
                    {
                        IfCondition = (GetVar(Data[1]).Equals(GetVar(Data[3])));
                    }

                    // Same for the others
                    else if (Data[2].Equals("!="))
                    {
                        IfCondition = (!GetVar(Data[1]).Equals(GetVar(Data[3])));
                    }

                    // Same here, we just turn the value's into doubles
                    else if (Data[2].Equals("<"))
                    {
                        IfCondition = (Convert.ToDouble(GetVar(Data[1])) < Convert.ToDouble(GetVar(Data[3])));
                    }

                    else if (Data[2].Equals(">"))
                    {
                        IfCondition = (Convert.ToDouble(GetVar(Data[1])) > Convert.ToDouble(GetVar(Data[3])));
                    }

                    else if (Data[2].Equals("<="))
                    {
                        IfCondition = (Convert.ToDouble(GetVar(Data[1])) <= Convert.ToDouble(GetVar(Data[3])));
                    }

                    else if (Data[2].Equals(">="))
                    {
                        IfCondition = (Convert.ToDouble(GetVar(Data[1])) >= Convert.ToDouble(GetVar(Data[3])));
                    }
                }
                 
                // Set's the flag to run commands to true
                else if (s.StartsWith("endif"))
                {
                    IfCondition = true;
                    Line++;
                    continue;
                }

                // If we can run commands
                if (IfCondition)
                {
                    // Console.Write
                    if (s.StartsWith("con:write"))
                    {
                        // "con:write" To write
                        String ToWrite = s.Split(new char[] { ' ' }, 2)[1];
                        Console.WriteLine(GetVar(ToWrite));
                    }

                    // Create Variables
                    else if (s.StartsWith("int") || s.StartsWith("string") || s.StartsWith("float"))
                    {
                        // If the Variable name doesn't follow the right convention, return, the error was already written
                        if (!AddVar(s))
                        {
                            return;
                        }
                    }

                    // Gets input and stores it into a variable
                    else if (s.StartsWith("con:in"))
                    {
                        // Get the Variables name, then set it to what the user inputs
                        Variables[s.Split(' ')[1]] = Console.ReadLine();
                    }

                    // Read in all of the text in a file, then write it to the console
                    else if (s.StartsWith("File:Read"))
                    {
                        Console.WriteLine(File.ReadAllText(s.Split(" ".ToCharArray(), 2)[1]));
                    }

                    // Write Parameter_2(Value) into Parameter_1(File)
                    else if (s.StartsWith("File:Write"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 3);
                        File.WriteAllText(GetVar(Data[1]), GetVar(Data[2]));
                    }

                    // Show a message box with the message Parameter_1(Message) with Yes and No buttons
                    else if (s.StartsWith("Msg:YN:show"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 2);
                        MessageBox.Show(Data[1], "", MessageBoxButtons.YesNo);
                    }

                    // Same as above, only with the OK button
                    else if (s.StartsWith("Msg:show"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 2);
                        MessageBox.Show(Data[1], "", MessageBoxButtons.OK);
                    }

                    // Ends the script
                    else if (s.StartsWith("End"))
                    {
                        Console.WriteLine("\nScript ended at line {0}.\n", Line);
                        return;
                    }

                    // Arithmetic Add
                    else if (s.StartsWith("+"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 3);

                        Console.WriteLine("{0} + {1} = {2}", Data[1], Data[2], (Convert.ToInt32(Data[1]) + Convert.ToInt32(Data[2])));
                    }

                    // Arithmetic Subtract
                    else if (s.StartsWith("-"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 3);

                        Console.WriteLine("{0} - {1} = {2}", Data[1], Data[2], (Convert.ToInt32(Data[1]) - Convert.ToInt32(Data[2])));
                    }

                    // Arithmetic Multiply
                    else if (s.StartsWith("*"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 3);

                        Console.WriteLine("{0} * {1} = {2}", Data[1], Data[2], (Convert.ToInt32(Data[1]) * Convert.ToInt32(Data[2])));
                    }

                    // Arithmetic Divide
                    else if (s.StartsWith("/"))
                    {
                        String[] Data = s.Split(" ".ToCharArray(), 3);

                        Console.WriteLine("{0} / {1} = {2}", Data[1], Data[2], (Convert.ToInt32(Data[1]) / Convert.ToInt32(Data[2])));
                    }
                }

                // Increase the Line count
                Line++;
            }

            // Write what line the Script ended on
            Console.WriteLine("\nScript ended at line {0}.\n", Line);
        }

        /// <summary>
        /// Add's a Variable, returns an error(And false) if it doesn't have the right naming convention
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        static bool AddVar(String type)
        {
            // Character to check for
            char Check;

            // If it's an int, set the Check to &
            if (type.StartsWith("int"))
            {
                Check = '&';
            }

            // If it's a string, set the Check to $
            else if (type.StartsWith("string"))
            {
                Check = '$';
            }

            // If it's a float, set the Check to @
            else
            {
                Check = '@';
            }

            // If the Variable's Name doesn't begin with the appropriate character, Write an error and stop the script
            if (type.Split(' ')[1][0] != Check)
            {
                Console.WriteLine("\nat {0}:\n\tExpecting {1} at the start of Variable name", Line, Check);
                return false;
            }

            // Otherwise, add the variable
            Variables.Add(type.Split(' ')[1], type.Split(new char[] { '=' }, 2)[1].Trim());

            return true;
        }
    }
}
