local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local LocalizationService = game:GetService("LocalizationService")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local FlagSettings = require(Modules.LuaApp.FlagSettings)


return function(props)
	local localization = props.localization

	return Roact.createElement(ExternalEventConnection, {
		event = LocalizationService:GetPropertyChangedSignal("RobloxLocaleId"),
		callback = function(newLocale)
			if FlagSettings:EnableLuaAppLoginPageForUniversalAppDev() then
				newLocale = LocalizationService.RobloxLocaleId
			end
			localization:SetLocale(newLocale)
		end,
	})
end
