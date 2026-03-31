local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")
local FFlagAvatarEditorFixSliderSensitivity = settings():GetFFlag("AvatarEditorFixSliderSensitivity")

local AESlidersThemeInfo = AvatarEditorThemeUtil.new()
AESlidersThemeInfo.__index = AESlidersThemeInfo

function AESlidersThemeInfo.new()
	local self = {}
	setmetatable(self, AESlidersThemeInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
				BackgroundImage = function() return nil end,
				DraggerOutline = {
					Size = UDim2.new(0, 48, 0, 48),
					Image = "AE/Graphic/gr-slider-01-console",
					Visible = false,
				},
				Slider = {
					Size = UDim2.new(0.8, 0, 0, 48),
					PosXOffset = 50,
					PosXScale = 0,
					PosY = 120,
				},
				BackgroundBar = {
					Size = UDim2.new(1, 0, 0, 12),
					Position = UDim2.new(0, 0, 0.5, 0),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar-console"
						or "rbxasset://textures/ui/Shell/AvatarEditor/scale/slide bar.png",
					SliceCenter = Rect.new(7, 5, 8, 7),
					AnchorPoint = Vector2.new(0, 0.5),
				},
				DraggerArea = FFlagAvatarEditorFixSliderSensitivity and {
					Size = UDim2.new(0, 48, 0, 48),
					AnchorPoint = Vector2.new(0.5, 0.5),
				},
				Dragger = {
					Size = UDim2.new(0, 48, 0, 48),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider-console"
						or "rbxasset://textures/ui/Shell/AvatarEditor/scale/slider.png",
					AnchorPoint = Vector2.new(0.5, 0.5),
					PosX = 0,
					PosY = 0,
				},
				Highlight = {
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 96, 0, 96),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider-hover-console" or "consoleDraggerHighlight",
					AnchorPoint = Vector2.new(0.5, 0.5),
				},
				DraggerButton = {
					Size = UDim2.new(1, 0, 1, 0),
				},
				FillBar = {
					Position = UDim2.new(0, -5, 0.5, 0),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar-console"
						or "rbxasset://textures/ui/Shell/AvatarEditor/scale/slide bar-filled.png",
					SliceCenter = Rect.new(7, 5, 8, 7),
					SizeY = 12,
					AnchorPoint = Vector2.new(0, 0.5),
				},
				DefaultLocationIndicator = {
					Size = UDim2.new(0, 24, 0, 24),
					Image = "AE/Graphic/gr-slider",
				},
				TextLabel = {
					Position = UDim2.new(0, 0, 0, -42),
					Size = UDim2.new(1, 0, 0, 30),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 30,
					Font = Enum.Font.SourceSans,
				},
			},
			Portrait = {
				BackgroundImage = function(backgroundSize, backgroundColor)
					return Roact.createElement("ImageLabel", {
						Position =  UDim2.new(0, 3, 0, 0),
						Visible = true,
						BorderSizePixel = 0,
						BackgroundColor3 = FFlagAvatarEditorEnableThemes and backgroundColor or Color3.new(1, 1, 1),
						Size = UDim2.new(1, -6, 0, backgroundSize)
					})
				end,
				DraggerOutline = {
					Size = UDim2.new(0, 24, 0, 24),
					Image = "AE/Graphic/gr-slider-01",
					Visible = true,
				},
				Slider = {
					Size = UDim2.new(0.8, 0, 0, 30),
					PosXScale = 0.1,
					PosXOffset = 0,
					PosY = 70,
				},
				BackgroundBar = {
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0.5, -3),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slide-bar-empty.png",
					SliceCenter = Rect.new(4, 4, 4, 4),
					AnchorPoint = Vector2.new(0, 0),
				},
				DraggerArea = FFlagAvatarEditorFixSliderSensitivity and {
					Size = UDim2.new(0, 40, 0, 40),
					AnchorPoint = Vector2.new(0, 0),
				},
				Dragger = {
					Size = UDim2.new(0, 24, 0, 24),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slider.png",
					AnchorPoint = FFlagAvatarEditorFixSliderSensitivity and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
					PosX = -16,
					PosY = FFlagAvatarEditorFixSliderSensitivity and -20 or -13,
				},
				Highlight = {
					Position = UDim2.new(0.5, -24, 0.5, -24),
					Size = UDim2.new(0, 48, 0, 48),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider-hover"
						or "rbxasset://textures/AvatarEditorImages/Sheet.png",
					AnchorPoint = Vector2.new(0, 0),
				},
				DraggerButton = {
					Size = UDim2.new(1, 32, 1, 32),
				},
				FillBar = {
					Position = UDim2.new(0, -5, 0, 12),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slide-bar-fill.png",
					SliceCenter = Rect.new(4, 4, 4, 4),
					SizeY = 6,
					AnchorPoint = Vector2.new(0, 0),
				},
				DefaultLocationIndicator = {
					Size = UDim2.new(0, 12, 0, 12),
					Image = "AE/Graphic/gr-slider-default-point",
				},
				TextLabel = {
					Position = UDim2.new(0, 0, 0.15, -32),
					Size = UDim2.new(0, 0, 0, 25),
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = FFlagAvatarEditorGothamFont and 16 or 14,
					Font = FFlagAvatarEditorGothamFont and Enum.Font.Gotham or Enum.Font.SourceSans,
				},
			},
			Landscape = {
				BackgroundImage = function(backgroundSize, backgroundColor)
					return Roact.createElement("ImageLabel", {
						Position =  UDim2.new(0, 3, 0, 13),
						Visible = true,
						BorderSizePixel = 0,
						BackgroundColor3 = FFlagAvatarEditorEnableThemes and backgroundColor or Color3.new(1, 1, 1),
						Size = UDim2.new(1, -6, 0, backgroundSize)
					})
				end,
				DraggerOutline = {
					Size = UDim2.new(0, 24, 0, 24),
					Image = "AE/Graphic/gr-slider-01",
					Visible = true,
				},
				Slider = {
					Size = UDim2.new(0.8, 0, 0, 30),
					PosXScale = 0,
					PosXOffset = 29,
					PosY = 54,
				},
				BackgroundBar = {
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0.5, -3),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slide-bar-empty.png",
					SliceCenter = Rect.new(4, 4, 4, 4),
					AnchorPoint = Vector2.new(0, 0),
				},
				DraggerArea = FFlagAvatarEditorFixSliderSensitivity and {
					Size = UDim2.new(0, 40, 0, 40),
					AnchorPoint = Vector2.new(0, 0),
				},
				Dragger = {
					Size = UDim2.new(0, 24, 0, 24),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slider.png",
					AnchorPoint = FFlagAvatarEditorFixSliderSensitivity and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
					PosX = -16,
					PosY = FFlagAvatarEditorFixSliderSensitivity and -20 or -13,
				},
				Highlight = {
					Position = UDim2.new(0.5, -24, 0.5, -24),
					Size = UDim2.new(0, 48, 0, 48),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slider-hover"
						or "rbxasset://textures/AvatarEditorImages/Sheet.png",
					AnchorPoint = Vector2.new(0, 0),
				},
				DraggerButton = {
					Size = UDim2.new(1, 32, 1, 32),
				},
				FillBar = {
					Position = UDim2.new(0, -5, 0, 12),
					Image = FFlagAvatarEditorEnableThemes and "AE/Graphic/gr-slide-bar-console"
						or "rbxasset://textures/AvatarEditorImages/Sliders/gr-slide-bar-fill.png",
					SliceCenter = Rect.new(4, 4, 4, 4),
					SizeY = 6,
					AnchorPoint = Vector2.new(0, 0),
				},
				DefaultLocationIndicator = {
					Size = UDim2.new(0, 12, 0, 12),
					Image = "AE/Graphic/gr-slider-default-point",
				},
				TextLabel = {
					Position = UDim2.new(0, 0, 0.15, -32),
					Size = UDim2.new(0, 0, 0, 25),
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = FFlagAvatarEditorGothamFont and 16 or 14,
					Font = FFlagAvatarEditorGothamFont and Enum.Font.Gotham or Enum.Font.SourceSans,
				},
			},
		},
		ColorThemes = {
			DarkTheme = {
				Background = Colors.Slate,
				SlideBarEmpty = Colors.Obsidian,
				Slider = Colors.Graphite,
				SliderOutline = Colors.Graphite,
				FillBarColor = Colors.Graphite,
				DefaultLocationFilled = Colors.Graphite,
				DefaultLocationEmpty = Colors.Obsidian,
				HighlightVisible = false,
				HighlightColor = Colors.BluePrimary,
				PageLabelTextColor = Colors.Pumice,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				Background = Colors.White,
				SlideBarEmpty = Colors.Gray4,
				Slider = Colors.White,
				SliderOutline = Colors.BluePrimary,
				FillBarColor = Colors.BluePrimary,
				DefaultLocationFilled = Colors.BluePrimary,
				DefaultLocationEmpty = Colors.Gray4,
				HighlightVisible = true,
				HighlightColor = Colors.BluePrimary,
				PageLabelTextColor = Colors.Gray2,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			XboxColorTheme = {
				Background = Colors.White,
				SlideBarEmpty = Colors.Gray4,
				Slider = Colors.BluePrimary,
				SliderOutline = Colors.BluePrimary,
				FillBarColor = Colors.BluePrimary,
				DefaultLocationFilled = Colors.BluePrimary,
				DefaultLocationEmpty = Colors.Gray4,
				HighlightVisible = true,
				HighlightColor = Colors.BluePrimary,
				PageLabelTextColor = Color3.new(1, 1, 1),
			},
		},
	}

	return self
end

function AESlidersThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AESlidersThemeInfo