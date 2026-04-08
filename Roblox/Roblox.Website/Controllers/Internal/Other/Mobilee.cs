using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Roblox.Exceptions;
using Roblox.Dto.Users;
using Roblox.Services;
using Roblox.Services.Exceptions;
using Roblox.Website.Middleware;
using BadRequestException = Roblox.Exceptions.BadRequestException;

namespace Roblox.Website.Controllers 
{
    [ApiController]
    [Route("/")]
    public class Mobilee : ControllerBase
    {
        public class LoginRequestV1
        {
            public string cvalue { get; set; } = "";
            public string password { get; set; } = "";
        }

        [HttpPostBypass("v1/login")]
        public async Task<dynamic> LoginV1([FromBody] LoginRequestV1 request)
        {
            await RateLimitCheck();
            
            string username = request.cvalue;
            string password = request.password;

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                throw new BadRequestException(0, "Username or password is missing.");

            string[] splittedUsername = username.Split('|');
            username = splittedUsername[0];

            UserInfo userInfo;
            try
            {
                userInfo = await services.users.GetUserByName(username);
            }
            catch (RecordNotFoundException)
            {
                throw new ForbiddenException(1, "Incorrect username or password. Please try again.");
            }

            if (!await services.users.VerifyPassword(userInfo.userId, password))
                throw new ForbiddenException(1, "Incorrect username or password. Please try again.");

            await CreateSessionAndSetCookie(userInfo.userId);

            return new
            {
                user = new
                {
                    id = userInfo.userId,
                    name = userInfo.username,
                    displayName = userInfo.username,
                },
                isBanned = userInfo.IsDeleted()
            };
        }

        private async Task RateLimitCheck()
        {
            var loginKey = "LoginV1:" + GetIP();
            var attemptCount = (await services.cooldown.GetBucketDataForKey(loginKey, TimeSpan.FromMinutes(10))).ToArray();
            if (!await services.cooldown.TryIncrementBucketCooldown(loginKey, 15, TimeSpan.FromMinutes(10), attemptCount, true))
            {
                throw new ForbiddenException(0, "Too many attempts.");
            }
        }

        private async Task CreateSessionAndSetCookie(long userId)
        {
            var sessionCookie = Middleware.SessionMiddleware.CreateJwt(new Middleware.JwtEntry()
            {
                sessionId = await services.users.CreateSession(userId),
                createdAt = DateTimeOffset.Now.ToUnixTimeSeconds(),
            });

            HttpContext.Response.Cookies.Append(Middleware.SessionMiddleware.CookieName, sessionCookie, new CookieOptions()
            {
                Secure = true,
                Expires = DateTimeOffset.Now.Add(TimeSpan.FromDays(364)),
                IsEssential = true,
                HttpOnly = true,
                Path = "/",
                SameSite = SameSiteMode.Lax,
            });
        }
    }
}
