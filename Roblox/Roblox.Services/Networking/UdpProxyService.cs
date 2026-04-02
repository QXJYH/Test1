using System.Net;
using System.Net.Sockets;

namespace Roblox.Services.Networking
{
    public class UdpProxy : IDisposable
    {
        private UdpClient? _clientSide;
        private UdpClient? _serverSide;
        private readonly IPEndPoint _serverEndPoint;
        private bool _isRunning;
        private CancellationTokenSource? _cts;

        public int PublicPort { get; }
        public int InternalPort { get; }

        public UdpProxy(int publicPort, int internalPort)
        {
            PublicPort = publicPort;
            InternalPort = internalPort;
            _serverEndPoint = new IPEndPoint(IPAddress.Loopback, internalPort);
        }

        public void Start()
        {
            if (_isRunning) return;
            _isRunning = true;
            _cts = new CancellationTokenSource();

            try
            {
                _clientSide = new UdpClient(PublicPort);
                _serverSide = new UdpClient(0);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UdpProxy] Failed to initialize ports {PublicPort}/{InternalPort}: {ex.Message}");
                _isRunning = false;
                return;
            }

            Task.Run(() => RunProxyLoop(_cts.Token));
        }

        private async Task RunProxyLoop(CancellationToken token)
        {
            IPEndPoint? lastClient = null;

            var clientToServer = Task.Run(async () =>
            {
                while (!token.IsCancellationRequested && _isRunning)
                {
                    try
                    {
                        var result = await _clientSide!.ReceiveAsync(token);
                        lastClient = result.RemoteEndPoint;
                        await _serverSide!.SendAsync(result.Buffer, result.Buffer.Length, _serverEndPoint);
                    }
                    catch (OperationCanceledException) { break; }
                    catch (ObjectDisposedException) { break; }
                    catch (Exception ex)
                    {
                        if (_isRunning) Console.WriteLine($"[UdpProxy] Client->Server Error: {ex.Message}");
                    }
                }
            }, token);

            var serverToClient = Task.Run(async () =>
            {
                while (!token.IsCancellationRequested && _isRunning)
                {
                    try
                    {
                        var result = await _serverSide!.ReceiveAsync(token);
                        if (lastClient != null)
                        {
                            await _clientSide!.SendAsync(result.Buffer, result.Buffer.Length, lastClient);
                        }
                    }
                    catch (OperationCanceledException) { break; }
                    catch (ObjectDisposedException) { break; }
                    catch (Exception ex)
                    {
                        if (_isRunning) Console.WriteLine($"[UdpProxy] Server->Client Error: {ex.Message}");
                    }
                }
            }, token);

            try
            {
                await Task.WhenAll(clientToServer, serverToClient);
            }
            catch (Exception) { /* Handled in loops */ }
        }

        public void Dispose()
        {
            _isRunning = false;
            _cts?.Cancel();
            _clientSide?.Dispose();
            _serverSide?.Dispose();
            _cts?.Dispose();
        }
    }

    public static class UdpProxyService
    {
        private static readonly System.Collections.Concurrent.ConcurrentDictionary<int, UdpProxy> _proxies = new();

        public static void StartProxy(int publicPort, int internalPort)
        {
            var proxy = new UdpProxy(publicPort, internalPort);
            if (_proxies.TryAdd(publicPort, proxy))
            {
                proxy.Start();
                Console.WriteLine($"[UdpProxy] Started proxy on port {publicPort} -> {internalPort}");
            }
        }

        public static void StopProxy(int publicPort)
        {
            if (_proxies.TryRemove(publicPort, out var proxy))
            {
                proxy.Dispose();
                Console.WriteLine($"[UdpProxy] Stopped proxy on port {publicPort}");
            }
        }
    }
}
