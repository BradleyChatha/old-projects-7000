using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScriptingEngine
{
    public class Error
    {
        public Error()
        {
            this.Errors = new List<string>();
            this.HasBeenErrors = false;
        }

        public void PushNewError(string ErrorMessage)
        {
            this.Errors.Add("Error: " + ErrorMessage);

            if (!this.HasBeenErrors)
                this.HasBeenErrors = true;
        }

        public void PrintAllErrors()
        {
            if (this.HasBeenErrors)
            {
                foreach (string E in this.Errors)
                { 
                    Console.WriteLine(E);
                }

                Console.WriteLine("Press any key to continue...");
                Console.ReadKey();
                Environment.Exit(-1);
            }
        }

#if DEBUG
        public List<string> GetErrors()
        {
            return this.Errors;
        }
#endif

        public bool HasBeenErrors
        {
            get;
            private set;
        }

        private List<string> Errors;
    }
}
