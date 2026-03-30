using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Roblox.Services.Exceptions;
using MVC = Microsoft.AspNetCore.Mvc;

namespace Roblox.Website.Controllers 
{
    public struct PendingVerification
    {
        public string Code;
        public DateTime Expiry;
    }

    [MVC.ApiController]
    [MVC.Route("/")]
    public class VerificationBot : ControllerBase
    {
        private static readonly Dictionary<string, PendingVerification> _verificationCodes = new();

        private void ValidateBotAuth()
        {
            if (Request.Headers["KRNT-botAPIkey"].ToString() != Roblox.Configuration.BotAuthorization)
            {
                throw new Exception("Internal");
            }
        }
        
        [HttpGetBypass("botapi/discord/send-verification")]
        public async Task<dynamic> Verification([FromQuery] string ID)
        {
            ValidateBotAuth();
            
            string code = new Random().Next(100000, 999999).ToString();
            
            _verificationCodes[ID] = new PendingVerification 
            { 
                Code = code, 
                Expiry = DateTime.UtcNow.AddMinutes(10) 
            };

            return new { success = true, code = code };
        }

        [HttpGetBypass("botapi/kickuser")]
        public async Task<dynamic> KickPlayerFromBot(long userId)
        {
            ValidateBotAuth();
            await services.gameServer.KickPlayer(userId);
            return new { success = true, message = "Kicked" };
        } 

        [HttpGetBypass("botapi/discord/verify-check")]
        public async Task<dynamic> VerifyCheck([FromQuery] string ID, [FromQuery] string code)
        {
            ValidateBotAuth();

            if (_verificationCodes.TryGetValue(ID, out var pending))
            {
                if (DateTime.UtcNow > pending.Expiry)
                {
                    _verificationCodes.Remove(ID);
                    return new { success = false, message = "Code expired" };
                }

                if (pending.Code == code)
                {
                    _verificationCodes.Remove(ID);
                    return new { success = true, message = "Verified" };
                }
            }

            return new { success = false, message = "Invalid code" };
        }

		[HttpGetBypass("botapi/discord/test-auth")]
		public async Task<dynamic> TestAuth()
		{
			ValidateBotAuth();
			return new { success = true, message = "Authenticated" };
		}
    }
}
