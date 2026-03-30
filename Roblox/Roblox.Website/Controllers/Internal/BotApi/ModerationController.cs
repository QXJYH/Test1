using Microsoft.AspNetCore.Mvc;
using Roblox.Website.Filters;

namespace Roblox.Website.Controllers;

[ApiController]
[Route("/")]
public class ModerationBot: ControllerBase
{
    private ServiceProvider services => ServiceProvider.GetInstance(this);

    [BotAuthorization]
    [HttpGetBypass("bot/kickuser")]
    public async Task<IActionResult> KickPlayerFromBot(long userId)
    {
        await services.gameServer.KickPlayer(userId);
        return Ok();
    } 
}
