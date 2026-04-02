using System.Diagnostics;

namespace Roblox.Services.Networking
{
    public static class UdpProxyService
    {
        private static readonly System.Collections.Concurrent.ConcurrentDictionary<int, Process> _proxies = new();

        public static void StartProxy(int publicPort, int internalPort)
        {
            if (string.IsNullOrEmpty(Configuration.SUDPPipePath))
            {
                Console.WriteLine("[UdpProxy] SUDPPipePath is not configured. Cannot start proxy.");
                return;
            }

            try
            {
                var startInfo = new ProcessStartInfo
                {
                    FileName = Configuration.SUDPPipePath,
                    Arguments = $"127.0.0.1 {internalPort} {publicPort}",
                    CreateNoWindow = true,
                    UseShellExecute = false,
                    RedirectStandardOutput = false,
                    RedirectStandardError = false
                };

                var process = Process.Start(startInfo);
                if (process != null)
                {
                    if (_proxies.TryAdd(publicPort, process))
                    {
                        Console.WriteLine($"[UdpProxy] Started sudppipe on port {publicPort} -> {internalPort}");
                    }
                    else
                    {
                        process.Kill();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UdpProxy] Failed to start sudppipe: {ex.Message}");
            }
        }

        public static void StopProxy(int publicPort)
        {
            if (_proxies.TryRemove(publicPort, out var process))
            {
                try
                {
                    if (!process.HasExited)
                    {
                        process.Kill();
                        Console.WriteLine($"[UdpProxy] Stopped sudppipe on port {publicPort}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[UdpProxy] Error stopping sudppipe on port {publicPort}: {ex.Message}");
                }
                finally
                {
                    process.Dispose();
                }
            }
        }
    }
}
