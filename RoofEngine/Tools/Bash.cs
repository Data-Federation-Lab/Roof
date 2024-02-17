using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

namespace RoofEngine.Tools
{
    public class Bash
    {
        /// <summary>
        /// Prepares a bash command
        /// </summary>
        /// <param name="command"></param>
        /// <returns></returns>
        public static Process PrepareCommand(string command)
        {
            var process = new System.Diagnostics.Process()
            {
                StartInfo = new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "/bin/bash",
                    Arguments = $"-c \"{command}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };

            return process;
        }

        public static void Run(string command)
        {
            try
            {
                using (var process = PrepareCommand(command))
                {
                    process.Start();

                    // Read the output to ensure the command was executed
                    string result = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    process.WaitForExit(); // Wait for the process to exit

                    if (!string.IsNullOrEmpty(error))
                    {
                        Console.WriteLine($"Error running command: {error}");
                    }
                    else
                    {
                        Console.WriteLine($"Command '{command}' executed successfully.");
                    }
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Error running command: {ex.Message}");
            }
        }

        public static void Run(Process preparedCommand)
        {
            try
            {
                using (var process = preparedCommand)
                {
                    process.Start();

                    // Read the output to ensure the command was executed
                    string result = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    process.WaitForExit(); // Wait for the process to exit

                    if (!string.IsNullOrEmpty(error))
                    {
                        Console.WriteLine($"Error running command: {error}");
                    }
                    else
                    {
                        Console.WriteLine($"Command '{preparedCommand.StartInfo.Arguments}' executed successfully.");
                    }
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Error running command: {ex.Message}");
            }
        }
    }
}