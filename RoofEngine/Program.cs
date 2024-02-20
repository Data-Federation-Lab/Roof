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

        private static void DisableService(string serviceName)
        {
            string disableServiceResult = Bash.Run($"sudo systemctl disable {serviceName}");
            string isServiceActive = Bash.Run($"sudo systemctl is-active {serviceName}");
            string isServiceEnabled = Bash.Run($"sudo systemctl is-enabled {serviceName}");

            #if DEBUG
            Console.WriteLine($"disableServiceResult: {disableServiceResult}");
            Console.WriteLine($"isServiceActive: {isServiceActive}");
            Console.WriteLine($"isServiceEnabled: {isServiceEnabled}");
            #endif

            if(isServiceActive.Contains("inactive") && isServiceEnabled.Contains("disabled"))
                Logger.Log($"Successfully disabled {serviceName}");
            else
                Logger.Log($"Failed to disable {serviceName}: {disableServiceResult}");
        }

        private static void DisableUnnecessaryServices()
        {
            #if DEBUG
            DisableService("ModemManager");
            #endif

            DisableService("cron");

            #if RELEASE
            DisableService("thd");
            #endif
        }
    }
}