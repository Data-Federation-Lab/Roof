using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.RegularExpressions;
using RoofEngine.Tools;

namespace RoofEngine
{
    public class MemoryManager
    {
        internal const int DEFAULT_MAX_PHYSICAL_MEMORY = 512;
        private static int SwapSize = 0;

        static MemoryManager()
        {
            Logger.Log("[MemoryManager] Setting swap size.");
            SetSwapSize();

            if(SwapSize > 0)
                Logger.Log("[MemoryManager] Swap size has been set.");
        }

        private static void SetSwapSize()
        {
           try
           {
                string usbInfo = Bash.Run("lsblk -o NAME,SIZE,VENDOR,MODEL,MOUNTPOINT -b -J");

                var regex = new Regex("\"size\":\"(\\d+)\"");
                var matches = regex.Matches(usbInfo);

                ulong totalSize = 0;
                foreach (Match match in matches)
                {
                    if (ulong.TryParse(match.Groups[1].Value, out ulong size))
                    {
                        totalSize += size;
                    }
                }

                if(totalSize > 0)
                {
                    #if DEBUG
                    Console.WriteLine($"Total USB Storage Size: {totalSize} bytes ({totalSize / 1024 / 1024 / 1024} GB)");
                    #endif

                    SwapSize = (int)(totalSize * 0.1);
                }
                else
                {
                    Logger.Log($"[MemoryManager] Failed to set swap size. Primary drive was not found.");
                }
           }
           catch(Exception ex)
           {
                Logger.Log($"[MemoryManager] Failed to set swap size. Exception: {ex.Message}");
           }
        }
    }
}