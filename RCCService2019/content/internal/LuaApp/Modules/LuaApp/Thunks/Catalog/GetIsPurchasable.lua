local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local CatalogWebApi = require(Modules.LuaApp.Components.Catalog.CatalogWebApi)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local SetBundleStatus = require(Modules.LuaApp.Actions.Catalog.SetBundleStatus)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)

local REASON_ALREADY_OWNED = "AlreadyOwned"

local function purchaseProductKeyMapper(productId)
	return CatalogConstants.BuyButtonInfoKey ..tostring(productId)
end

return function(networkImpl, productId)
	return PerformFetch.Single(purchaseProductKeyMapper(productId), function(store)
		if store:getState().CatalogAppReducer.BundlesStatus[tostring(productId)] ~= nil then
			return Promise.resolve()
		end

		return CatalogWebApi.GetIsPurchasable(networkImpl, productId):andThen(
			function(result)
				local data = result.responseBody
				if data then
					if data.purchasable then
						store:dispatch(SetBundleStatus(productId, CatalogConstants.PurchaseStatus.Purchasable))
					elseif not data.purchasable and data.reason == REASON_ALREADY_OWNED then
						store:dispatch(SetBundleStatus(productId, CatalogConstants.PurchaseStatus.Owned))
					elseif not data.purchasable then
						store:dispatch(SetBundleStatus(productId, CatalogConstants.PurchaseStatus.NotPurchasable))
					end

					return Promise.resolve(data)
				else
					Logging.warn("Response from GetIsPurchasable is malformed!")
					return Promise.reject({HttpError = Enum.HttpError.OK})
				end
			end,
			function(err)
				return Promise.reject(err)
			end
		)
	end)
end