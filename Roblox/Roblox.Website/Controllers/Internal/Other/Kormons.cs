// using System.Collections.Concurrent;
// using System.ComponentModel.DataAnnotations;
// using Microsoft.AspNetCore.Http;
// using Microsoft.AspNetCore.Mvc;
// using Newtonsoft.Json;
// using Roblox.Website.Middleware;
// using Roblox.Services;
// using Roblox.Services.App.FeatureFlags;
// using Roblox.Services.Exceptions;
// using BadRequestException = Roblox.Exceptions.BadRequestException;
// using MVC = Microsoft.AspNetCore.Mvc;

// namespace Roblox.Website.Controllers 
// {
//     [MVC.ApiController]
//     [MVC.Route("/")]
//     public class Kormons : ControllerBase
//     {
// 		private static readonly ConcurrentDictionary<string, KormonsAuthData> UserAuthCodes = new();
		
// 		private void ValidateApiKey()
//         {
// #if DEBUG == false
// 	        if (Request.Headers["apiKey"].ToString() != Roblox.Configuration.KormonsApiKey)
// 	        {
// 		        throw new RobloxException(400, 0, "Code not found");
// 	        }
// #endif
//         }
		
// 		private class KormonsAuthData
// 		{
// 			public long userId { get; set; }
// 			public string username { get; set; }
// 			public DateTime createdAt { get; set; }
// 		}

// 		[HttpGetBypass("kormons/login")]
// 		public async Task<MVC.IActionResult> KormonsLogin()
// 		{
// 			if (userSession == null)
// 			{
// 				return Redirect("/");
// 			}

// 			var code = GenerateCallbackCode(32);
// 			var user = await services.users.GetUserById(userSession.userId);

// 			UserAuthCodes[code] = new KormonsAuthData
// 			{
// 				userId = userSession.userId,
// 				username = user.username,
// 				createdAt = DateTime.UtcNow
// 			};
// 			return Redirect($"https://kormons.kornet.lat/login/callback?code={code}");
// 		}

// 		[HttpGetBypass("kormons/usercheck")]
// 		public async Task<dynamic> KormonsCheck([System.ComponentModel.DataAnnotations.Required] string code)
// 		{
// 			ValidateApiKey();
// 			Cleanup();

// 			if (UserAuthCodes.TryRemove(code, out var User))
// 			{
// 				return new
// 				{
// 					userId = User.userId,
// 					username = User.username
// 				};
// 			}

// 			throw new RobloxException(400, 0, "Bad or expired auth code");
// 		}
		
// 		private string GenerateCallbackCode(int length)
// 		{
// 			const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
// 			var random = new Random();
// 			return new string(Enumerable.Repeat(chars, length)
// 				.Select(s => s[random.Next(s.Length)]).ToArray());
// 		}

// 		private void Cleanup()
// 		{
// 			var now = DateTime.UtcNow;
// 			var Expired = UserAuthCodes
// 				.Where(kv => (now - kv.Value.createdAt).TotalMinutes > 20)
// 				.Select(kv => kv.Key)
// 				.ToList();

// 			foreach (var code in Expired)
// 			{
// 				UserAuthCodes.TryRemove(code, out _);
// 			}
// 		}
//     }
// }