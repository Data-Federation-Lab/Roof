using System;
using RoofEngine.Tools;

namespace RoofEngine
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Logger.Log("Starting the Roof Engine...");

            Logger.Log("Disabling unnecessary services...");
            DisableUnnecessaryServices();
        }

        private static void DisableUnnecessaryServices()
        {
            #if DEBUG
            Bash.Run("sudo systemctl disable ModemManager");
            #endif

            Bash.Run("sudo systemctl disable cron");
            Bash.Run("sudo systemctl disable thd");
        }
    }
}