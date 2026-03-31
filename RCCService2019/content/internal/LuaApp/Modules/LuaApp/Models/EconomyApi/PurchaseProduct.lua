--[[
	Docs: https://economy.roblox.com/docs#!/Product/post_v1_purchases_products_productId

	Provides a model for response from product purchase request.
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FFlagLuaAppPurchaseErrorToastRefactor = settings():GetFFlag("LuaAppPurchaseErrorToastRefactor2")

local PurchaseProduct = {}

function PurchaseProduct.new()
	return {}
end

function PurchaseProduct.fromJsonData(jsonData)
	local self = PurchaseProduct.new()

	ArgCheck.isType(jsonData, "table", "PurchaseProduct.fromJsonData's jsonData")
	ArgCheck.isType(jsonData.purchased, "boolean", "PurchaseProduct.fromJsonData's jsonData.purchased")
	ArgCheck.isType(jsonData.productId, "number", "PurchaseProduct.fromJsonData's jsonData.productId")
	ArgCheck.isType(jsonData.title, "string", "PurchaseProduct.fromJsonData's jsonData.title")
	ArgCheck.isType(jsonData.showDivId, "string", "PurchaseProduct.fromJsonData's jsonData.showDivId")
	ArgCheck.isType(jsonData.shortfallPrice, "number", "PurchaseProduct.fromJsonData's jsonData.shortfallPrice")
	ArgCheck.isType(jsonData.statusCode, "number", "PurchaseProduct.fromJsonData's jsonData.statusCode")

	if type(jsonData) == "table" then
		self.purchased = jsonData.purchased == true
		self.productId = tonumber(jsonData.productId)
		self.title = tostring(jsonData.title)
		if FFlagLuaAppPurchaseErrorToastRefactor then
			self.showDivId = tostring(jsonData.showDivId)
		else
			self.showDivID = tostring(jsonData.showDivId)
		end
		self.shortfallPrice = tonumber(jsonData.shortfallPrice)
		self.statusCode = tonumber(jsonData.statusCode)
	end

	return self
end

return PurchaseProduct