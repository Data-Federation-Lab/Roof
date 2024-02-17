using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RoofEngine.Tools
{
    /// <summary>
    /// Logger class for logging messages to the console and to a log file.
    /// TODO: Fully implement with log levels, file logging, etc.
    /// </summary>
    public class Logger
    {
        public static void Log(string message)
        {
            Console.WriteLine(message);
        }
    }
}