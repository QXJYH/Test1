local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Modules = CoreGui.RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)

local CatalogWebApi = {}

local function valuesAsCommaSeparatedString(myTable)
	local result = ""
	for _,v in pairs(myTable) do
		result = result .. (result ~= "" and "," or "")
		result = result .. tostring(v)
	end
	return result
end

function CatalogWebApi.FetchAssetThumbnails(requestImpl, assetIds, thumbnailSize)
	ArgCheck.isType(assetIds, "table", "CatalogWebApi.FetchAssetThumbnails expects a table of assetIds")
	ArgCheck.isType(thumbnailSize, "string", "CatalogWebApi.FetchAssetThumbnails expects thumbnailSize to a string")
	local query = Url:makeQueryString({
		size = thumbnailSize .. "x" .. thumbnailSize,
		format = "png",
		assetIds = assetIds,
	})
	local url = Url.THUMBNAILS_URL .. "/v1/assets?" .. query
	return requestImpl(url, "GET")
end

function CatalogWebApi.FetchBundleThumbnails(requestImpl, bundleIds, thumbnailSize)
	ArgCheck.isType(bundleIds, "table", "CatalogWebApi.FetchBundleThumbnails request expects bundleIds to be a table")
	local bundleCsv = valuesAsCommaSeparatedString(bundleIds)
	local query = Url:makeQueryString({
		size = thumbnailSize .. "x" .. thumbnailSize,
		format = "png",
		bundleIds = bundleCsv,
	})
	local url = string.format("%sv1/bundles/thumbnails?%s", Url.THUMBNAILS_URL, query)
	return requestImpl(url, "GET")
end

function CatalogWebApi.FetchBundles(requestImpl, bundleIds)
	ArgCheck.isType(bundleIds, "table", "CatalogWebApi.FetchBundles request expects bundleIds to be a table")
	local bundleCsv = valuesAsCommaSeparatedString(bundleIds)
	local query = Url:makeQueryString({
		bundleIds = bundleCsv,
	})
	local url = string.format("%sv1/bundles/details?%s", Url.CATALOG_URL, query)
	return requestImpl(url, "GET")
end

function CatalogWebApi.PurchaseProduct(requestImpl, productId, expectedPrice, expectedSellerId)
	ArgCheck.isType(productId, "string", "CatalogWebApi.PurchaseProduct: productId")
	ArgCheck.isNonNegativeNumber(expectedPrice, "CatalogWebApi.PurchaseProduct: expectedPrice")
	ArgCheck.isType(expectedSellerId, "string", "CatalogWebApi.PurchaseProduct: expectedSellerId")

	local url = string.format("%sv1/purchases/products/%s", Url.ECONOMY_URL, productId)
	local body = HttpService:JSONEncode({
		expectedCurrency = CatalogConstants.ExpectedCurrencyRobux,
		expectedPrice = tostring(expectedPrice),
		expectedSellerId = tostring(expectedSellerId),
	})

	return requestImpl(url, "POST", { postBody = body })
end

function CatalogWebApi.GetIsPurchasable(requestImpl, productId)
	ArgCheck.isType(productId, "string", "CatalogWebApi.GetIsPurchasable: productId")
	local url = string.format("%sv1/products/%s?showPurchasable=true", Url.ECONOMY_URL, productId)
	return requestImpl(url, "GET")
end

return CatalogWebApi
