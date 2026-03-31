--[[
	Documentation of endpoint:
		https://economy.roblox.com/docs#!/Product/post_v1_purchases_products_productId
]]

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local HttpService = game:GetService("HttpService")

local Modules = CoreGui.RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local t = require(CorePackages.Packages.t)
local EconomyTypes = require(Modules.LuaApp.Types.EconomyTypes)

local GetFFlagLuaAppNewEconomyApi = require(Modules.LuaApp.Flags.GetFFlagLuaAppNewEconomyApi)

local PurchaseProductCheck = t.tuple(t.callback, t.integer, EconomyTypes.PurchaseDetail)
local function PurchaseProduct(requestImpl, productId, purchaseDetail)
	ArgCheck.assert(PurchaseProductCheck(requestImpl, productId, purchaseDetail))

	local url = ("%sv1/purchases/products/%i"):format(Url.ECONOMY_URL, productId)
	local body = HttpService:JSONEncode(purchaseDetail)

	return requestImpl(url, "POST", { postBody = body })
end

local function PurchaseProductOld(requestImpl, productID, expectedCurrency, expectedPrice, expectedSellerID)
	ArgCheck.isNonNegativeNumber(productID, "productID")
	ArgCheck.isNonNegativeNumber(expectedCurrency, "expectedCurrency")
	ArgCheck.isNonNegativeNumber(expectedPrice, "expectedPrice")
	ArgCheck.isNonNegativeNumber(expectedSellerID, "expectedSellerID")

	local url = string.format("%sapi/item.ashx?rqtype=purchase&productID=%d&expectedCurrency=%d"..
		"&expectedPrice=%d&expectedSellerID=%d",
		Url.BASE_URL_SECURE, productID, expectedCurrency, expectedPrice, expectedSellerID)

	return requestImpl(url, "POST", { postBody = "" })
end

local function PurchaseProductWrapper(...)
	if GetFFlagLuaAppNewEconomyApi() then
		return PurchaseProduct(...)
	else
		return PurchaseProductOld(...)
	end
end

return PurchaseProductWrapper
