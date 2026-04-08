using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Roblox.Exceptions;
using Roblox.Dto.Users;
using Roblox.Dto.Authentication;
using Roblox.Services;
using Roblox.Services.Exceptions;
using Roblox.Services.App.FeatureFlags;
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
            FeatureCheck();
            await RateLimitCheck();
            string username = request.cvalue;
            string password = request.password;
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                throw new BadRequestException((int)LoginError400.UsernamePasswordRequired, "Username or password is missing.");

            // Format: {username}|{2facode}
            // string[] splittedUsername = username.Split('|');

            // username = splittedUsername[0];
            // string totpCode = splittedUsername.Length == 2 ? splittedUsername[1] : "";

            UserInfo userInfo;
            try
            {
                userInfo = await services.users.GetUserByName(username);
            }
            catch (RecordNotFoundException)
            {
                throw new ForbiddenException((int)LoginError403.IncorrectCredentials, "Incorrect username or password. Please try again.");
            }

            // if (await Login(userInfo.username, request.password, userInfo.userId, totpCode, isPasswordLeaked))
            if (await Login(userInfo.username, request.password, userInfo.userId))
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

        [HttpGetBypass("client/pbe")]
        [HttpPostBypass("client/pbe")]
        [HttpGetBypass("mobile/pbe")]
        public OkResult PBE()
        {
            return Ok();
        }

        private void FeatureCheck()
        {
            try
            {
                FeatureFlags.FeatureCheck(FeatureFlag.LoginEnabled);
            }
            catch (RobloxException)
            {
                throw new RobloxException(503, (int)LoginError503.ServiceUnavailable, "Login is currently disabled. Please try again later.");
            }
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
        //private async Task<bool> Login(string username, string password, long userId, string? totpCode, bool isPasswordLeaked, bool? skip2FA = false)
        private async Task<bool> Login(string username, string password, long userId)
        {
            FeatureCheck();
            await RateLimitCheck();
            //get totp info
            try
            {
                if (!await services.users.VerifyPassword(userId, password))
                    throw new ForbiddenException((int)LoginError403.IncorrectCredentials, "Incorrect username or password. Please try again");
            }
            catch (RecordNotFoundException)
            {
                throw new ForbiddenException((int)LoginError403.AccountLocked, "Your account has been locked. Please reset your password to unlock your account.");
            }

            // if (skip2FA == true)
            //     return true;

            // if (await services.users.GetTotpStatus(userId) == TotpStatus.Enabled)
            // {
            //     TotpInfo? totpInfo = await services.users.GetTotp(userId);
            //     //null check
            //     if (string.IsNullOrEmpty(totpCode))
            //         throw new ForbiddenException((int)LoginError403.IncorrectCredentials, $"You have 2FA enabled. Please login with this username format {username}|2FA Code");

            //     //verify totp code
            //     if (!services.users.VerifyTotp(totpInfo.secret, totpCode))
            //         throw new ForbiddenException((int)LoginError403.IncorrectCredentials, "Incorrect 2FA code. Please try again.");
            // }

            return true;
        }

        private async Task<string> CreateSessionAndSetCookie(long userId)
        {
            var sessionCookie = Middleware.SessionMiddleware.CreateJwt(new Middleware.JwtEntry()
            {
                sessionId = await services.users.CreateSession(userId),
                createdAt = DateTimeOffset.Now.ToUnixTimeSeconds(),
            });
            // will be removed later this is just a hack to get the website to work :sob:
            HttpContext.Response.Cookies.Append(Middleware.SessionMiddleware.CookieName, sessionCookie, new CookieOptions()
            {
                Domain = ".kornet.lat",
                Secure = false,
                Expires = DateTimeOffset.Now.Add(TimeSpan.FromDays(364)),
                IsEssential = true,
                Path = "/",
                SameSite = SameSiteMode.Lax,
            });
            return sessionCookie;
        }
    }
}
