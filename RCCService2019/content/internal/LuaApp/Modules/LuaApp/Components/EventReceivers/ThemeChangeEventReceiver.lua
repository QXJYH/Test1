local CoreGui = game:GetService("CoreGui")
local PlayerService = game:GetService("Players")
local CorePackages = game:GetService("CorePackages")
local AppStorageService = game:GetService("AppStorageService")
local NotificationService = game:GetService("NotificationService")

local Modules = CoreGui.RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local FetchTheme = require(Modules.LuaApp.Thunks.FetchTheme)
local StylePalette = require(CorePackages.AppTempCommon.LuaApp.Style.StylePalette)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local AppStorageUtilities = require(Modules.LuaApp.Thunks.Authentication.AppStorageUtilities)
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local EnableLuaAppLoginPageForUniversalAppDev = FlagSettings.EnableLuaAppLoginPageForUniversalAppDev()

local ThemeChangeEventReceiver = Roact.Component:extend("ThemeChangeEventReceiver")

local ThemeChangeType = {
	ThemeUpdate = "ThemeUpdate",
}

function ThemeChangeEventReceiver:init()
	local robloxEventReceiver = self.props.RobloxEventReceiver
	local networking = self.props.networking

	self.appStyle = self._context.AppStyle

	self.changeTheme = function(themeName)
		local currentStyle = self.appStyle.style
		local stylePalette = StylePalette.new(currentStyle)
		stylePalette:updateTheme(themeName)
		local newStyle = stylePalette:currentStyle()
		NotificationService.SelectedTheme = themeName
		self.appStyle:update(newStyle)
	end

	self.updateTheme = function()
		return FetchTheme(networking, PlayerService.LocalPlayer.UserId):andThen(
			function(result)
				local theme = result
				if EnableLuaAppLoginPageForUniversalAppDev then
					AppStorageUtilities.setTheme(theme)
					AppStorageUtilities.flush()
				end
				self.changeTheme(theme)
			end)
	end

	self.tokens = {
		robloxEventReceiver:observeEvent("UserThemeTypeChangeNotification", function(detail, detailType)
			if detail.Type == ThemeChangeType.ThemeUpdate then
				self.updateTheme()
			end
		end),
		EnableLuaAppLoginPageForUniversalAppDev and AppStorageService.ItemWasSet:Connect(
			function(key, value)
				if key == LocalStorageKey.Theme then
					self.changeTheme(value)
				end
			end
		) or nil,
	}
end

function ThemeChangeEventReceiver:render()
end

function ThemeChangeEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:disconnect()
	end
end

return RoactServices.connect({
	networking = RoactNetworking,
	guiService = AppGuiService,
})(ThemeChangeEventReceiver)