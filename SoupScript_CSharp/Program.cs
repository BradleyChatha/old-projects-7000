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

            }
        }
    }
}
