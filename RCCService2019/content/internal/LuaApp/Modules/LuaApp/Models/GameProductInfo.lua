--[[
	{
		"universeId": string,
		"isForSale": boolean,
		"productId": number,
		"price": number,
		"sellerId": number,
	}
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Result = require(Modules.LuaApp.Result)

local GameProductInfo = {}

function GameProductInfo.new()
	local self = {}
	return self
end

function GameProductInfo.mock(universeId)
	local self = GameProductInfo.new()
	self.universeId = universeId
	self.isForSale = true
	self.productId = 12345
	self.price = 5
	self.sellerId = 6789
	return self
end

function GameProductInfo.fromJsonData(gameProductInfoJson)
	if type(gameProductInfoJson.universeId) ~= "number" or
		type(gameProductInfoJson.isForSale) ~= "boolean" or
		type(gameProductInfoJson.productId) ~= "number" or
		type(gameProductInfoJson.price) ~= "number" or
		type(gameProductInfoJson.sellerId) ~= "number" then
		return Result.error("invalid data type")
	else
		local self = GameProductInfo.new()
		self.universeId = tostring(gameProductInfoJson.universeId, "number")
		self.isForSale = gameProductInfoJson.isForSale
		self.productId = gameProductInfoJson.productId
		self.price = gameProductInfoJson.price
		self.sellerId = gameProductInfoJson.sellerId

		return Result.success(self)
	end
end

return GameProductInfo