local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local getPurchaseErrorTypeFromErrorResponse = require(Modules.LuaApp.getPurchaseErrorTypeFromErrorResponse)
local PurchaseErrorLocalizationKeys = require(Modules.LuaApp.PurchaseErrorLocalizationKeys)

return function(data)
	return function(store)
		local purchaseErrorType = getPurchaseErrorTypeFromErrorResponse(data)
		local toastMessage = PurchaseErrorLocalizationKeys[purchaseErrorType]

		store:dispatch(SetCurrentToastMessage({
			toastType = ToastType.PurchaseMessage,
			toastMessage = toastMessage,
		}))
	end
end