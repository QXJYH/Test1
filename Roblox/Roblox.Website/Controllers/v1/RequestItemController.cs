using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Roblox.Services;
using System.Net.Http;
using System.IO;

namespace Roblox.Website.Controllers
{
    [ApiController]
    [Route("/apisite/request-item/v1")]
    [IgnoreAntiforgeryToken]
    public class RequestItemController : ControllerBase
    {
        public class SubmitRequest
        {
            [Required] public string type { get; set; }
            [Required] public string name { get; set; }
            public string description { get; set; }
            public int robuxPrice { get; set; }
            public int tixPrice { get; set; }
            public bool isLimited { get; set; }
            public int stock { get; set; }
            public string? assetUrl { get; set; }
        }

        [HttpPost("submit")]
        public async Task<IActionResult> Submit([FromForm] SubmitRequest request, IFormFile? rbxmFile, IFormFile? objFile)
        {
            try
            {
                await services.requestItem.Initialize();

                string? rbxmPath = null;
                string? objPath = null;
                
                var uploadDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "requests");
                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                if (rbxmFile != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(rbxmFile.FileName)}";
                    var distinctPath = Path.Combine(uploadDir, fileName);
                    using (var stream = new FileStream(distinctPath, FileMode.Create))
                    {
                        await rbxmFile.CopyToAsync(stream);
                    }
                    rbxmPath = $"/uploads/requests/{fileName}";
                }

                if (objFile != null)
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(objFile.FileName)}";
                    var distinctPath = Path.Combine(uploadDir, fileName);
                    using (var stream = new FileStream(distinctPath, FileMode.Create))
                    {
                        await objFile.CopyToAsync(stream);
                    }
                    objPath = $"/uploads/requests/{fileName}";
                }

                if (request.type != "Roblox")
                {
                    long fee = 200;
                    long userBalance = await services.economy.GetBalance(safeUserSession.userId, Roblox.Models.Economy.CurrencyType.Robux);
                    if (userBalance < fee)
                    {
                        return BadRequest(new { message = $"Insufficient funds. You need {fee} Robux to upload a UGC item." });
                    }
                    
                    await services.economy.IncrementCurrency(
                        Roblox.Models.Assets.CreatorType.User,
                        safeUserSession.userId, 
                        Roblox.Models.Economy.CurrencyType.Robux, 
                        -fee
                    );
                }

                await services.requestItem.InsertRequest(new RequestItemService.ItemRequestEntry
                {
                    type = request.type,
                    name = request.name,
                    description = request.description,
                    robux_price = request.robuxPrice,
                    tix_price = request.tixPrice,
                    is_limited = request.isLimited,
                    stock = request.stock,
                    asset_url = request.assetUrl,
                    rbxm_path = rbxmPath,
                    obj_path = objPath,
                    status = 0,
                    submitter_id = safeUserSession.userId
                });

                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return StatusCode(500, new { message = ex.ToString() });
            }
        }

        [HttpGet("list")]
        public async Task<IActionResult> List()
        {
            var requests = await services.requestItem.GetPendingRequests();
            return Ok(requests);
        }

        public class BuildRequest
        {
            public long id { get; set; }
            public string action { get; set; }
            public string? name { get; set; }
            public int? robuxPrice { get; set; }
            public int? tixPrice { get; set; }
            public bool? isLimited { get; set; }
            public int? stock { get; set; }
            public long? creatorId { get; set; }
        }

        [HttpPost("approve")]
        public async Task<IActionResult> Approve([FromBody] BuildRequest req)
        {
            if (req.action == "approve")
            {
                var request = await services.requestItem.GetRequestById(req.id);
                if (request == null) return NotFound(new { message = "Request not found in database" });

                string finalName = !string.IsNullOrEmpty(req.name) ? req.name : request.name;
                int finalRobux = req.robuxPrice ?? request.robux_price;
                int finalTix = req.tixPrice ?? request.tix_price;
                bool finalLimited = req.isLimited ?? request.is_limited;
                int finalStock = req.stock ?? request.stock;
                long finalCreatorId = req.creatorId ?? request.submitter_id;

                Roblox.Models.Assets.Type assetType;
                switch (request.type)
                {
                    case "Shirt": assetType = Roblox.Models.Assets.Type.Shirt; break;
                    case "Pants": assetType = Roblox.Models.Assets.Type.Pants; break;
                    case "T-Shirt": assetType = Roblox.Models.Assets.Type.TeeShirt; break; 
                    case "Face": assetType = Roblox.Models.Assets.Type.Face; break;
                    case "Gear": assetType = Roblox.Models.Assets.Type.Gear; break;
                    default: assetType = Roblox.Models.Assets.Type.Hat; break;
                }

                var uploadRoot = @"C:\Users\Administrator\Downloads\kornet\2016-roblox-main\public";

                string filePath = null;
                Stream stream = null;

                if (!string.IsNullOrEmpty(request.rbxm_path))
                {
                    filePath = Path.Combine(uploadRoot, request.rbxm_path.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
                }
                else if (!string.IsNullOrEmpty(request.obj_path))
                {
                    filePath = Path.Combine(uploadRoot, request.obj_path.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
                }

                if (filePath != null)
                {
                    if (!System.IO.File.Exists(filePath))
                    {
                        Console.WriteLine($"[Error] Asset file not found: {filePath}");
                        return BadRequest(new { message = "Asset file not found on disk", path = filePath });
                    }
                    Console.WriteLine($"[Info] Processing approval for file: {filePath}");
                    stream = System.IO.File.OpenRead(filePath);
                }
                else if (!string.IsNullOrEmpty(request.asset_url))
                {
                     Console.WriteLine($"[Info] No file path, attempting to download from URL: {request.asset_url}");
                     try 
                     {
                        using var http = new HttpClient();
                        http.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
                        var bytes = await http.GetByteArrayAsync(request.asset_url);
                        stream = new MemoryStream(bytes);
                     }
                     catch (Exception ex)
                     {
                         Console.WriteLine($"[Error] Failed to download asset: {ex.Message}");
                         return BadRequest(new { message = $"Failed to download asset from URL: {request.asset_url}. Error: {ex.Message}" });
                     }
                }
                else 
                {
                     return BadRequest(new { message = "Database entry has no file paths AND no asset_url. This request cannot be processed." });
                }

                using (stream)
                {
                    var result = await services.assets.CreateAsset(
                        finalName,
                        request.description,
                        finalCreatorId,
                        Roblox.Models.Assets.CreatorType.User,
                        finalCreatorId,
                        stream,
                        assetType,
                        Roblox.Models.Assets.Genre.All,
                        Roblox.Models.Assets.ModerationStatus.ReviewApproved
                    );

                    await services.assets.SetItemPrice(result.assetId, finalRobux, finalTix);
                    
                    await services.assets.UpdateAssetMarketInfo(
                        result.assetId,
                        true, 
                        finalLimited,
                        finalLimited,
                        finalStock > 0 ? finalStock : null,
                        null
                    );

                    await services.requestItem.UpdateRequestStatus(req.id, 1);
                }
            } 
            else if (req.action == "decline")
            {
                await services.requestItem.UpdateRequestStatus(req.id, 2);
            }
            else
            {
                return BadRequest(new { message = "Invalid action" });
            }

            return Ok(new { success = true });
        }
    }
}
