using System;
using System.Collections.Generic;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Roblox.Website.Middleware;
using Roblox.Services.App.FeatureFlags;
using BadRequestException = Roblox.Exceptions.BadRequestException;
using MVC = Microsoft.AspNetCore.Mvc;

namespace Roblox.Website.Controllers 
{
    [MVC.ApiController]
    [MVC.Route("/")]
    public class ClientData : ControllerBase 
    {	
		[HttpGet("login/negotiate.ashx"), HttpGet("login/negotiateasync.ashx")]
		public object Negotiate(string suggest)
		{
			HttpContext.Response.Cookies.Append(".ROBLOSECURITY", suggest, new CookieOptions
			{
				Domain = null,
				HttpOnly = true,
				Secure = true,
				Expires = DateTimeOffset.Now.Add(TimeSpan.FromDays(364)),
				IsEssential = true,
				Path = "/",
				SameSite = SameSiteMode.Lax,
			});

			return suggest;
		}	
		
		// TODO: Before source release, make these actually fucking work
		// It's so incredibly insecure having these patched in RCC, but i cannot find a fix for some reason cause RCC SUCKS. 
		// (i know why now and i'm just too lazy to fix it, but please do this in the future)
 		[HttpGetBypass("GetAllowedSecurityKeys")]
        public MVC.ActionResult<dynamic> AllowedSecurity()
        {
            return true;
        }
		
		[HttpGetBypass("GetAllowedMD5Hashes")]
        public MVC.ActionResult<dynamic> AllowedMD5Hashes()
        {
            List<string> allowedList = new List<string>()
            {
				"97e93df61c3357531585cebb22d2edff",
				"053974fb1131dda3fc75534b08576b67",
				"2e71951cc3566e2ab558b9f8a8f1c510",
				"0f84ee329a636e6c23829514d1adc89c",
				"abc9d2132ef2c21101804d8e25e0413f", //2017L Prod
                "bba43f967698feff49038f51b391b48e", //2018L Prod
                "4022369076d608d1a99b7b3d250e4de5", //2018L RAGELoader Debug
                "9d7975454cee0e948e35cdc1fb55f92a", //2019E Prod
                "15c69e21a90ed1d10e686db71d62c955", //2019M Prod
                "ff693c76d9c15e7e97eb09e133942412", //2020L Prod
                "7da7086e7f3a739873fa5970ef586e98", //2021M Prod
                "1fd6e7becff68acc140b2db17e24c86e", //2021M June 6,
            };

            return new { data = allowedList };
        }

        [HttpGetBypass("GetAllowedSecurityVersions")]
        public MVC.ActionResult<dynamic> AllowedSecurityVersions()
        {
            List<string> allowedList = new List<string>()
            {  	
				"0.463.0pcplayer",
				"0.450.0pcplayer",
				"0.395.0pcplayer",
				"0.376.0pcplayer",
				"0.355.0pcplayer",
				"2.355.0iosapp",
				"0.314.0pcplayer",
				"0.300.1pcplayer",
				"0.300.0pcplayer",
				"0.285.0pcplayer",
				"0.283.0pcplayer",
				"0.275.0pcplayer",
				"0.235.0pcplayer",
				"0.206.0pcplayer",
				"0.201.0pcplayer",
				"INTERNALandroidapp",
				"INTERNALiosapp",
				"INTERNALpcplayer"
            };
			
            return new { data = allowedList };
        }
		
		[HttpGetBypass("Setting/QuietGet/{type}")]
		public MVC.ActionResult<dynamic> GetAppSettings(string type, [MVC.FromQuery] string? apiKey = "")
		{
			try
			{
				if (!Configuration.AllowedQuietGetJson.Any(x => x.Equals(type, StringComparison.OrdinalIgnoreCase)))
				{
					Console.WriteLine($"[RetrieveClientFFlags] disallowed JSON trying to be requested!");
					return "Go away";
				}

				bool use2015 = apiKey.Equals("2015MRCC-2015-2015-2015-2015MidRCC15", StringComparison.OrdinalIgnoreCase);
				
				string fileName = type;
				if (use2015)
				{
					fileName = type + "2015";
					Console.WriteLine($"[RetrieveClientFFlags] Using 2015 flags for: {type}");
				}

				string jsonFilePath = Path.Combine(Configuration.JsonDataDirectory, fileName + ".json");
				
				if (use2015 && !System.IO.File.Exists(jsonFilePath))
				{
					Console.WriteLine($"[RetrieveClientFFlags] 2015 flasg not found, falling back");
					jsonFilePath = Path.Combine(Configuration.JsonDataDirectory, type + ".json");
				}

				string jsonContent = System.IO.File.ReadAllText(jsonFilePath);
				dynamic? clientAppSettingsData = JsonConvert.DeserializeObject<ExpandoObject>(jsonContent);

				return clientAppSettingsData ?? "";
			}
			catch (Exception ex)
			{
				Console.WriteLine($"[RetrieveClientFFlags] could not get FFlags: {ex.Message}");
				return new {};
			}
		}
		
		[HttpGetBypass("Setting/24")]
		public async Task<MVC.ActionResult> GetAppSettings2014()
		{
			string json = "2014LFFlags";
			json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "2014LFFlags.json");
			string content = await System.IO.File.ReadAllTextAsync(json);
			return Content(content, "text/plain");
		}
		
		[HttpGetBypass("/v1/settings/application")]
		public async Task<MVC.IActionResult> RCCNewApplication(string applicationName)
		{
			string json = "PCDesktopClient";
			if (!string.IsNullOrEmpty(applicationName))
			{
				switch (applicationName)
				{
					case "PCDesktopClient":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "PCDesktopClient.json");
						break;

					case "StudioApp":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "StudioApp.json");
						break;

					case "PCStudioApp":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "PCStudioApp.json");
						break;

					case "AndroidApp":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "AndroidApp.json");
						break;

					case "6sxp8X2Y02settingsislwkgoated":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "RCCService.json");
						break;
					// Make this configurable in appsettyings
					case "RCCServicesettingsislwkgoated":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "RCCService.json");
						break;
						
					case "GD5Z5gO1n0gYX1P":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "PCDesktopClient.json");
						break;
				}
			}

			if (!System.IO.File.Exists(json))
			{
				return NotFound("{}");
			}

			string content = await System.IO.File.ReadAllTextAsync(json);
			return Content(content, "text/plain");
		}

		[HttpGetBypass("/v2/settings/application")]
		public async Task<MVC.IActionResult> RCCNewApplicationV2(string applicationName)
		{
			string json = "PCDesktopClient2021";
			if (!string.IsNullOrEmpty(applicationName))
			{
				switch (applicationName)
				{
					case "PCDesktopClient2021":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "PCDesktopClient2021.json");
						break;
					
					case "AndroidApp":
						json = System.IO.Path.Combine(Configuration.JsonDataDirectory, "AndroidAppV2.json");
						break;
				}
			}

			if (!System.IO.File.Exists(json))
			{
				return NotFound("{}");
			}

			string content = await System.IO.File.ReadAllTextAsync(json);
			return Content(content, "text/plain");
		}
		
		[HttpPostBypass("Game/ChatFilter.ashx")]
		public dynamic ChatFilter()
		{
			try
			{
				var text = HttpContext.Request.Form["text"].ToString();
				var userId = HttpContext.Request.Form["userId"].ToString();
				var placeId = HttpContext.Request.Headers["placeId"].ToString();
				var gameInstanceId = HttpContext.Request.Headers["gameInstanceID"].ToString();

				var filteredText = services.filter.FilterText(text);
				
				return new
				{
					data = new 
					{
						white = filteredText,
						black = filteredText
					}
				};
			}
			catch (Exception ex)
			{
				return new
				{
					data = new 
					{
						white = "#",
						black = "#"
					}
				};
			}
		}
		
		[HttpPostBypass("moderation/v2/filtertext")]
        [HttpPostBypass("moderation/filtertext")]
        public dynamic GetModerationText()
        {
            var text = services.filter.FilterText(HttpContext.Request.Form["text"].ToString());
            return new
            {
                success = true,
                data = new
                {
                    AgeUnder13 = text,
                    Age13OrOver = text,
                    white = text,
                    black = text
                }
            };
        }

		// // Make an actual filter function later
		// [HttpPostBypass("moderation/filtertext")]
        // public dynamic GetModerationText()
        // {
        //     //var text = FilterFunction(HttpContext.Request.Form["text"].ToString());
		// 	var text = HttpContext.Request.Form["text"].ToString();
        //     return new
        //     {
        //         success = true,
        //         data = new 
        //         {
        //             white = text,
        //             black = text
        //         }
        //     };
        // }
		
        // [HttpPostBypass("moderation/v2/filtertext")]
        // public dynamic GetModerationTextV2()
        // {
        //     //var text = FilterFunction(HttpContext.Request.Form["text"].ToString());
		// 	var text = HttpContext.Request.Form["text"].ToString();
        //     var json = new
        //     {
        //         success = true,
        //         data = new
        //         {
        //             AgeUnder13 = text,
        //             Age13OrOver = text,
        //         }
        //     };
        //     string jsonString = JsonConvert.SerializeObject(json);
        //     return Content(jsonString, "application/json");
        // }
	}
}	