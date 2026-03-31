local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AEBodyColorsThemeInfo = AvatarEditorThemeUtil.new()
AEBodyColorsThemeInfo.__index = AEBodyColorsThemeInfo

function AEBodyColorsThemeInfo.new()
	local self = {}
	setmetatable(self, AEBodyColorsThemeInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
				BackgroundImageBackgroundColor = Color3.fromRGB(140, 140, 140),
				BodyColorImageColor3 = Color3.fromRGB(140, 140, 140),
				CheckMark = not FFlagAvatarEditorEnableThemes and Roact.createElement("ImageLabel", {
					Image = "rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-checkmark.png",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 32, 0, 32),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 4,
				}) or nil,
				Border = {
					Image = "AE/Graphic/gr-console-color-block-border",
				},
				ColorBlock = {
					Image = "AE/Graphic/gr-console-color-block",
				},
				EquippedFrame = {
					Image = "AE/Graphic/gr-console-color-selector",
				},
			},
			Portrait = {
				BackgroundImageBackgroundColor = Color3.new(1, 1, 1),
				BodyColorImageColor3 = Color3.new(255, 255, 255),
				CheckMark = nil,
				Border = {
					Image = "AE/Graphic/gr-phone-color-block-border",
				},
				ColorBlock = {
					Image = "AE/Graphic/gr-phone-color-block",
				},
				EquippedFrame = {
					Image = "AE/Graphic/gr-phone-color-selector",
				},
			},
			Landscape = {
				BackgroundImageBackgroundColor = Color3.new(1, 1, 1),
				BodyColorImageColor3 = Color3.new(255, 255, 255),
				CheckMark = nil,
				Border = {
					Image = "AE/Graphic/gr-tablet-color-block-border",
				},
				ColorBlock = {
					Image = "AE/Graphic/gr-tablet-color-block",
				},
				EquippedFrame = {
					Image = "AE/Graphic/gr-tablet-color-selector",
				},
			},
		},
		ColorThemes = {
			DarkTheme = {
				BackgroundTransparency = 1,
				BorderColor = Colors.Gray3,
				SelectedRing = Colors.White,
				BackgroundColor = FFlagAvatarEditorEnableThemes and Colors.Slate or Color3.new(1, 1, 1),
			},
			ClassicTheme = {
				BackgroundTransparency = 0,
				BorderColor = Colors.Gray3,
				SelectedRing = Colors.BluePrimary,
				BackgroundColor = FFlagAvatarEditorEnableThemes and Colors.White or Color3.new(1, 1, 1),
			},
			XboxColorTheme = {
				BackgroundTransparency = 0,
				BorderColor = Colors.Gray3,
				SelectedRing = Colors.White,
				BackgroundColor = Color3.fromRGB(140, 140, 140),
			},
		},
	}

	return self
end

function AEBodyColorsThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEBodyColorsThemeInfo