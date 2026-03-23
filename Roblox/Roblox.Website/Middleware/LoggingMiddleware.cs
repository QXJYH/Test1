using System.Diagnostics;
using Microsoft.AspNetCore.Http.Extensions;
using Roblox.Website.Lib;

namespace Roblox.Website.Middleware;

public class RobloxLoggingMiddleware
{
    private RequestDelegate _next;
    public RobloxLoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext ctx)
    {
        var watch = new Stopwatch();
        watch.Start();
        await _next(ctx);
        watch.Stop();

        var path = ctx.Request.Path.Value ?? "";
        var query = ctx.Request.QueryString.Value ?? "";
        
        var consoleStr = $"[{ctx.Request.Method.ToUpper()}] {path}{query} - Status: {ctx.Response.StatusCode} - {watch.ElapsedMilliseconds}ms";
        Console.WriteLine(consoleStr);
    }
}

public static class RobloxLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRobloxLoggingMiddleware(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RobloxLoggingMiddleware>();
    }
}