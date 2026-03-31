local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)
local AppStorageService = game:GetService("AppStorageService")

local AppStorageUtilities = {}

function AppStorageUtilities.setRobloxLocaleId(locale)
	-- lua app will be responsive to this change in the future
	AppStorageService:SetItem(LocalStorageKey.RobloxLocaleId, locale)
end

function AppStorageUtilities.setGameLocaleId(locale)
	AppStorageService:SetItem(LocalStorageKey.GameLocaleId, locale)
end

function AppStorageUtilities.setTheme(theme)
	-- lua app will be responsive to this change in the future
	AppStorageService:SetItem(LocalStorageKey.Theme, theme)
end

function AppStorageUtilities.flush()
	AppStorageService:flush()
end

return AppStorageUtilities