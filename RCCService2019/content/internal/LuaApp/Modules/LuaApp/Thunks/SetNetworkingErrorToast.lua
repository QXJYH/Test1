local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local getLocalizedToastStringFromHttpError = require(Modules.LuaApp.getLocalizedToastStringFromHttpError)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)

return function(err)
	return function(store)
		local toastMessage = getLocalizedToastStringFromHttpError(err.HttpError, err.StatusCode)
		if toastMessage ~= nil then
			store:dispatch(SetCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = toastMessage,
			}))
		end
	end
end