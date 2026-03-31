local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local SetBundleStatus = require(Modules.LuaApp.Actions.Catalog.SetBundleStatus)
local CatalogWebApi = require(Modules.LuaApp.Components.Catalog.CatalogWebApi)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
local ApiFetchEconomyCurrency = require(Modules.LuaApp.Thunks.ApiFetchEconomyCurrency)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local SetPurchaseErrorToast = require(Modules.LuaApp.Thunks.SetPurchaseErrorToast)
local PurchaseProduct = require(Modules.LuaApp.Models.EconomyApi.PurchaseProduct)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local UNKNOWN_NETWORK_ERROR_TABLE = { HttpError = Enum.HttpError.OK }

local function updateRobux(networking, store)
	local localUserId = store:getState().LocalUserId
	ArgCheck.isNonEmptyString(localUserId, "Thunk.PurchaseProduct.updateRobux.localUserId")
	if typeof(localUserId) == "string" and localUserId ~= "" then
		store:dispatch(ApiFetchEconomyCurrency(networking, localUserId, true))
	end
end

local function purchaseProductKeyMapper(productId)
	return CatalogConstants.PurchaseProductKey ..tostring(productId)
end

return function(networkImpl, productId, expectedPrice, expectedSellerId, customPurchaseErrorHandler)
	return PerformFetch.Single(purchaseProductKeyMapper(productId), function(store)
		return CatalogWebApi.PurchaseProduct(networkImpl, productId, expectedPrice, expectedSellerId):andThen(
			function(result)
				local data = result.responseBody
				if type(data) == "table" then
					local purchaseProductData = PurchaseProduct.fromJsonData(data)

					if purchaseProductData.purchased then
						store:dispatch(SetBundleStatus(productId, CatalogConstants.PurchaseStatus.Owned))
						updateRobux(networkImpl, store)
						return Promise.resolve(purchaseProductData)
					else
						store:dispatch(SetPurchaseErrorToast(purchaseProductData))
						return Promise.reject(purchaseProductData)
					end
				else
					local err = UNKNOWN_NETWORK_ERROR_TABLE
					Logging.warn("Response from PurchaseProduct is malformed!")
					store:dispatch(SetNetworkingErrorToast(err))
					return Promise.reject(err)
				end
			end,
			function(err)
				if type(err) ~= "table" or err.HttpError == nil then
					err = UNKNOWN_NETWORK_ERROR_TABLE
				end
				store:dispatch(SetNetworkingErrorToast(err))
				return Promise.reject(err)
			end
		)
	end)
end