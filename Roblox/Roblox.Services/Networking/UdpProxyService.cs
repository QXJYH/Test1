using System.Net;
using System.Net.Sockets;

namespace Roblox.Services.Networking
{
    public class UdpProxy : IDisposable
    {
        private readonly UdpClient _clientSide;
        private readonly UdpClient _serverSide;
        private readonly IPEndPoint _serverEndPoint;
        private bool _isRunning;
        private Task _clientToServerTask;
        private Task _serverToClientTask;

        public int PublicPort { get; }
        public int InternalPort { get; }

        public UdpProxy(int publicPort, int internalPort)
        {
            PublicPort = publicPort;
            InternalPort = internalPort;
            _serverEndPoint = new IPEndPoint(IPAddress.Loopback, internalPort);

            _clientSide = new UdpClient(publicPort);
            _serverSide = new UdpClient();
        }

        public void Start()
        {
            if (_isRunning) return;
            _isRunning = true;

            _clientToServerTask = Task.Run(async () =>
            {
                IPEndPoint? remoteClientEndPoint = null;
                while (_isRunning)
                {
                    try
                    {
                        var result = await _clientSide.ReceiveAsync();
                        remoteClientEndPoint = result.RemoteEndPoint;
                        await _serverSide.SendAsync(result.Buffer, result.Buffer.Length, _serverEndPoint);
                    }
                    catch (Exception) when (!_isRunning) { }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[UdpProxy] Error in Client -> Server: {ex.Message}");
                    }
                }
            });

            _serverToClientTask = Task.Run(async () =>
            {
                IPEndPoint? remoteClientEndPoint = null;
                while (_isRunning)
                {
                    try
                    {
                        var result = await _serverSide.ReceiveAsync();
                    }
                    catch (Exception) when (!_isRunning) { }
                }
            });
            
            _isRunning = false;
            _clientSide.Dispose();
            _serverSide.Dispose();
            StartRobust();
        }

        private void StartRobust()
        {
            _isRunning = true;
            _ = Task.Run(async () =>
            {
                IPEndPoint? lastClient = null;
                
                var clientTask = Task.Run(async () =>
                {
                    while (_isRunning)
                    {
                        try
                        {
                            var result = await _clientSide.ReceiveAsync();
                            lastClient = result.RemoteEndPoint;
                            await _serverSide.SendAsync(result.Buffer, result.Buffer.Length, _serverEndPoint);
                        }
                        catch (Exception) when (!_isRunning) { break; }
                        catch (Exception ex) { Console.WriteLine($"[UdpProxy] Client->Server Error: {ex.Message}"); }
                    }
                });

                var serverTask = Task.Run(async () =>
                {
                    while (_isRunning)
                    {
                        try
                        {
                            var result = await _serverSide.ReceiveAsync();
                            if (lastClient != null)
                            {
                                await _clientSide.SendAsync(result.Buffer, result.Buffer.Length, lastClient);
                            }
                        }
                        catch (Exception) when (!_isRunning) { break; }
                        catch (Exception ex) { Console.WriteLine($"[UdpProxy] Server->Client Error: {ex.Message}"); }
                    }
                });

                await Task.WhenAll(clientTask, serverTask);
            });
        }

        public void Dispose()
        {
            _isRunning = false;
            _clientSide?.Dispose();
            _serverSide?.Dispose();
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
