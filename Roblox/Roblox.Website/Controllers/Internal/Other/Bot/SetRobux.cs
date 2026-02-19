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
using Roblox.Services;
using Roblox.Services.Exceptions;
using Roblox.Models.Users;
using Roblox.Models.Economy;
using Roblox.Dto.Assets;
using Roblox.Models.Assets;
using Roblox.Website.WebsiteModels.Asset;

namespace Roblox.Website.Controllers 
{
    [MVC.ApiController]
    [MVC.Route("/")]
    public class RobuxBot : ControllerBase
    {
        private void ValidateBotAuth()
        {
            if (Request.Headers["KRNT-botAPIkey"].ToString() != Roblox.Configuration.BotAuthorization)
            {
                throw new Exception("Internal");
            }
        }

        [HttpGetBypass("botapi/discord/get-robux")]
        public async Task<dynamic> GetRobux([FromQuery] string ID)
        {
            ValidateBotAuth();
            
            try
            {
                var userId = await services.users.GetUserIdFromDiscordId(ID);
                var balance = await services.economy.GetUserBalance(userId);

                return new 
                {
                    success = true,
                    robux = balance.robux,
                    tickets = balance.tickets
                };
            }
            catch (RecordNotFoundException)
            {
                throw new RobloxException(400, 0, "Account not found");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetRobux error: {ex.Message}");
                throw new RobloxException(500, 0, "Internal error");
            }
        }
		
        [HttpGetBypass("botapi/discord/set-robux")]
        public async Task<dynamic> SetRobux([FromQuery] string ID, [FromQuery] string amount)
        {
            ValidateBotAuth();
            
            try
            {
                if (!long.TryParse(amount, out long TargetAmount) || TargetAmount < 0)
                {
                    throw new RobloxException(400, 0, "Invalid amount");
                }

                var userId = await services.users.GetUserIdFromDiscordId(ID);
                var currentBalance = await services.economy.GetUserBalance(userId);

                await services.economy.SetUserBalance(userId, TargetAmount, currentBalance.tickets);

                return new 
                {
                    success = true,
                    Status = $"Successfully set Robux to {TargetAmount}",
                    OldBalance = currentBalance.robux,
                    NewBalance = TargetAmount
                };
            }
            catch (RecordNotFoundException)
            {
                throw new RobloxException(400, 0, "Account not found");
            }
            catch (RobloxException)
            {
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"SetRobux error: {ex.Message}");
                throw new RobloxException(500, 0, "Internal error");
            }
        }
    }
}
