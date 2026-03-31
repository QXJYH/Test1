local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AEShopButton = AvatarEditorThemeUtil.new()
AEShopButton.__index = AEShopButton

function AEShopButton.new()
	local self = {}
	setmetatable(self, AEShopButton)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {},
			Portrait = {},
			Landscape = {},
		},
		ColorThemes = {
			DarkTheme = {
				Background = Colors.Slate,
				BorderColor = Colors.White,
				TextColor = Colors.White,
				BackgroundTransparency = 0,
				BorderSizePixel = 1,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				Background = Colors.BluePrimary,
				BorderColor = Colors.White,
				TextColor = Colors.White,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
		},
	}

	return self
end

function AEShopButton:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEShopButton
