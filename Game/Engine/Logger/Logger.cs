using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;

namespace Game.Engine
{
    /// <summary>
    /// The level which the a message being logged it at.
    /// </summary>
    public enum LogLevel
    {
        /// <summary>
        /// Used for simple logs, just general information (e.g. GPU, CPU, drivers).
        /// </summary>
        Info = 0,

        /// <summary>
        /// Logs information which is only needed being development (e.g. position of pets).
        /// </summary>
        Debug,

        /// <summary>
        /// Logs about anytime something goes wrong (recoverable or not).
        /// </summary>
        Error
    }

    public class Logger
    {
        /// <summary>
        /// Initalises the logger class.
        /// Creates a folder if it dosesn't exist.
        /// Creates the log file.
        /// </summary>
        public static void Init()
        {
            if(!Directory.Exists("Logs"))
                Directory.CreateDirectory("Logs");

            string Time = DateTime.Now.ToString("h-mm-ss-ms");
            Writer = new StreamWriter("Logs\\" + Time + ".log");

            Log(LogLevel.Info, "Init logger");
        }

        /// <summary>
        /// Uninitalises the logger class, when the logging is complete.
        /// Disposes of the StreamWriter object.
        /// </summary>
        public static void Deinit()
        {
            Log(LogLevel.Info, "Deinit logger");
            Writer.Dispose();
        }

        /// <summary>
        /// Writes the log to both the console and the log file.
        /// Logs the time, level, calling function (with parameters and return type), then the message.
        /// The debug log level doesn't get compiled into the executable unless it is in debug build.
        /// </summary>
        /// <param name="Level">The level which the log is set to.</param>
        /// <param name="Message">The message to be logged. See LogLevel.</param>
        public static void Log(LogLevel Level, string Message, [CallerFilePath] string File = "")
        {
            StackTrace Trace = new StackTrace();
            string Output = $"({DateTime.Now.ToString("h:mm:ss:ms tt")}) [{Level.ToString() }] {{{Path.GetFileName(File)}${Trace.GetFrame(1).GetMethod().ToString()}}} {Message}";

#if DEBUG
            if (Level == LogLevel.Debug)
            {
                Console.WriteLine(Output);
                Writer.WriteLine(Output);
                return;
            }
#endif
            Console.WriteLine(Output);
            Writer.WriteLine(Output);
        }

        private static StreamWriter Writer;
    }
}
