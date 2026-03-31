--[[

	Provides a model for response from product purchase request for game items.
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FFlagLuaAppPurchaseErrorToastRefactor = settings():GetFFlag("LuaAppPurchaseErrorToastRefactor2")

local GameItemPurchaseProduct = {}

function GameItemPurchaseProduct.new()
	return {}
end

function GameItemPurchaseProduct.fromJsonData(jsonData)
	local self = GameItemPurchaseProduct.new()

	ArgCheck.isType(jsonData, "table", "GameItemPurchaseProduct.fromJsonData's jsonData")
	ArgCheck.isType(jsonData.productId, "number", "GameItemPurchaseProduct.fromJsonData's jsonData.productId")
	ArgCheck.isType(jsonData.title, "string", "GameItemPurchaseProduct.fromJsonData's jsonData.title")
	ArgCheck.isType(jsonData.showDivID, "string", "GameItemPurchaseProduct.fromJsonData's jsonData.showDivID")
	ArgCheck.isType(jsonData.shortfallPrice, "number", "GameItemPurchaseProduct.fromJsonData's jsonData.shortfallPrice")

	if jsonData.statusCode then
		ArgCheck.isType(jsonData.statusCode, "number", "GameItemPurchaseProduct.fromJsonData's jsonData.statusCode")
	end

	if type(jsonData) == "table" then
		self.productId = tonumber(jsonData.productId)
		self.title = tostring(jsonData.title)
		if FFlagLuaAppPurchaseErrorToastRefactor then
			self.showDivId = tostring(jsonData.showDivID)
		else
			self.showDivID = tostring(jsonData.showDivID)
		end
		self.shortfallPrice = tonumber(jsonData.shortfallPrice)
		self.statusCode = tonumber(jsonData.statusCode)
	end

	return self
end

return GameItemPurchaseProduct