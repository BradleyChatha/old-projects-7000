using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace SoupScript_CSharp
{
    class Program
    {
        static int Line = 0;
        static Dictionary<String, String> Variables = new Dictionary<String, String>();

        static void Main(string[] args)
        {
            while (true)
            {
                Console.Clear();

                Console.Write("Enter command: ");
                Command(Console.ReadLine());
            }
        }

        static void Command(String com)
        {
            switch (com.ToLower())
            {
                case "exit":
                case "stop":
                case "logout":
                    Environment.Exit(0);
                    break;

                case "compile":
                    Console.Write("Enter file: ");
                    Compile(Console.ReadLine());
                    break;
            }
        }

        static void Compile(String file)
        {
            if (!File.Exists(file))
            {
                Console.WriteLine("\nERROR: File not found!\n");
                return;
            }

            String[] Contents = File.ReadAllLines(file);

            for (int i = 0; i < Contents.Length; i++)
            {
                String s = Contents[i];

                if (s.StartsWith("con:write"))
                {
                    String ToWrite = s.Split(new char[] { ' ' }, 2)[1];
                    Console.WriteLine(ToWrite);
                }

                else if (s.StartsWith("int") || s.StartsWith("string") || s.StartsWith("float"))
                {
                    if (!AddVar(s))
                    {
                        return;
                    }
                }

                else if (s.StartsWith("con:in"))
                {
                    Variables[s.Split(' ')[1]] = Console.ReadLine();
                }

                Line++;
            }
        }

        static bool AddVar(String type)
        {
            char Check;

            if (type.Equals("int"))
            {
                Check = '&';
            }
            else if (type.Equals("string"))
            {
                Check = '$';
            }
            else
            {
                Check = '@';
            }

            if (type[0] != Check)
            {
                Console.WriteLine("\nat {0}:\n\tExpecting {1} at the start of Variable name", Line, Check);
                return false;
            }

            Variables.Add(type.Split(' ')[1], type.Split(new char[] { '=' }, 2)[1].Trim());

            return true;
        }
    }
}
