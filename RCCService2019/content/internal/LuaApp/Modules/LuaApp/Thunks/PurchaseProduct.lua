local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local t = require(CorePackages.Packages.t)
local Promise = require(Modules.LuaApp.Promise)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local getPurchaseErrorTypeFromErrorResponse = require(Modules.LuaApp.getPurchaseErrorTypeFromErrorResponse)
local PurchaseErrorLocalizationKeys = require(Modules.LuaApp.PurchaseErrorLocalizationKeys)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local PurchaseProductRequest = require(Modules.LuaApp.Http.Requests.PurchaseProduct)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local SetPurchaseErrorToast = require(Modules.LuaApp.Thunks.SetPurchaseErrorToast)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GameItemPurchaseProduct = require(Modules.LuaApp.Models.GameItemPurchaseProduct)
local EconomyTypes = require(Modules.LuaApp.Types.EconomyTypes)

local FFlagLuaAppPurchaseErrorToastRefactor = settings():GetFFlag("LuaAppPurchaseErrorToastRefactor2")
local GetFFlagLuaAppNewEconomyApi = require(Modules.LuaApp.Flags.GetFFlagLuaAppNewEconomyApi)

local PurchaseProduct = {}

local function purchaseProductKeyMapper(productID)
	return "luaapp.purchaseproduct." .. productID
end

local PostCheck = t.tuple(t.callback, t.numberPositive, EconomyTypes.PurchaseDetail, t.optional(t.callback))

local function Post(networkImpl, productId, purchaseDetail, customPurchaseErrorHandler)
	ArgCheck.assert(PostCheck(networkImpl, productId, purchaseDetail, customPurchaseErrorHandler))

	return PerformFetch.Single(purchaseProductKeyMapper(productId), function(store)
		return PurchaseProductRequest(networkImpl, productId, purchaseDetail)
			:andThen(function(result)
				if FFlagLuaAppPurchaseErrorToastRefactor then
					local data = result.responseBody
					if type(data) == "table" then
						local purchaseProductData = GameItemPurchaseProduct.fromJsonData(data)

						if purchaseProductData.statusCode ~= nil and purchaseProductData.statusCode ~= 200 then
							-- If the customHandler did not handle this error, we use the default behavior,
							-- which is to set an error toast.
							if customPurchaseErrorHandler == nil or
								customPurchaseErrorHandler(purchaseProductData) == false then
								store:dispatch(SetPurchaseErrorToast(purchaseProductData))
							end

							return Promise.reject(purchaseProductData)
						else
							return Promise.resolve(purchaseProductData)
						end
					else
						Logging.warn("Response from PurchaseProduct is malformed!")
						store:dispatch(SetNetworkingErrorToast({HttpError = Enum.HttpError.OK}))
						return Promise.reject({HttpError = Enum.HttpError.OK})
					end
				else
					local data = result.responseBody

					if data ~= nil and type(data) == "table" then
						if data.statusCode ~= nil and tonumber(data.statusCode) ~= 200 then
							-- If the customHandler did not handle this error, we use the default behavior,
							-- which is to set an error toast.
							if customPurchaseErrorHandler == nil or
								customPurchaseErrorHandler(data) == false then
								local purchaseErrorType = getPurchaseErrorTypeFromErrorResponse(data)
								local message = PurchaseErrorLocalizationKeys[purchaseErrorType]
								store:dispatch(SetCurrentToastMessage({
									toastType = ToastType.PurchaseMessage,
									toastMessage = message,
								}))
							end

							return Promise.reject(data)
						else
							return Promise.resolve(data)
						end
					else
						Logging.warn("Response from PurchaseProduct is malformed!")
						store:dispatch(SetNetworkingErrorToast({HttpError = Enum.HttpError.OK}))
						return Promise.reject({HttpError = Enum.HttpError.OK})
					end
				end
			end,
			function(err)
				store:dispatch(SetNetworkingErrorToast(err))
				return Promise.reject(err)
			end
		)
	end)
end

local function OldPost(networkImpl, productID, expectedCurrency, expectedPrice, expectedSellerID,
	customPurchaseErrorHandler)
	ArgCheck.isNonNegativeNumber(productID, "productID")
	ArgCheck.isNonNegativeNumber(expectedCurrency, "expectedCurrency")
	ArgCheck.isNonNegativeNumber(expectedPrice, "expectedPrice")
	ArgCheck.isNonNegativeNumber(expectedSellerID, "expectedSellerID")

	return PerformFetch.Single(purchaseProductKeyMapper(productID), function(store)
		return PurchaseProductRequest(networkImpl, productID, expectedCurrency,
			expectedPrice, expectedSellerID):andThen(
			function(result)
				if FFlagLuaAppPurchaseErrorToastRefactor then
					local data = result.responseBody
					if type(data) == "table" then
						local purchaseProductData = GameItemPurchaseProduct.fromJsonData(data)

						if purchaseProductData.statusCode ~= nil and purchaseProductData.statusCode ~= 200 then
							-- If the customHandler did not handle this error, we use the default behavior,
							-- which is to set an error toast.
							if customPurchaseErrorHandler == nil or
								customPurchaseErrorHandler(purchaseProductData) == false then
								store:dispatch(SetPurchaseErrorToast(purchaseProductData))
							end

							return Promise.reject(purchaseProductData)
						else
							return Promise.resolve(purchaseProductData)
						end
					else
						Logging.warn("Response from PurchaseProduct is malformed!")
						store:dispatch(SetNetworkingErrorToast({HttpError = Enum.HttpError.OK}))
						return Promise.reject({HttpError = Enum.HttpError.OK})
					end
				else
					local data = result.responseBody

					if data ~= nil and type(data) == "table" then
						if data.statusCode ~= nil and tonumber(data.statusCode) ~= 200 then
							-- If the customHandler did not handle this error, we use the default behavior,
							-- which is to set an error toast.
							if customPurchaseErrorHandler == nil or
								customPurchaseErrorHandler(data) == false then
								local purchaseErrorType = getPurchaseErrorTypeFromErrorResponse(data)
								local message = PurchaseErrorLocalizationKeys[purchaseErrorType]
								store:dispatch(SetCurrentToastMessage({
									toastType = ToastType.PurchaseMessage,
									toastMessage = message,
								}))
							end

							return Promise.reject(data)
						else
							return Promise.resolve(data)
						end
					else
						Logging.warn("Response from PurchaseProduct is malformed!")
						store:dispatch(SetNetworkingErrorToast({HttpError = Enum.HttpError.OK}))
						return Promise.reject({HttpError = Enum.HttpError.OK})
					end
				end
			end,
			function(err)
				store:dispatch(SetNetworkingErrorToast(err))
				return Promise.reject(err)
			end
		)
	end)
end

function PurchaseProduct.Post(...)
	if GetFFlagLuaAppNewEconomyApi() then
		return Post(...)
	else
		return OldPost(...)
	end
end

function PurchaseProduct.GetPostingStatus(state, productID)
	return PerformFetch.GetStatus(state, purchaseProductKeyMapper(productID))
end

return PurchaseProduct