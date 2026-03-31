local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local Constants = require(Modules.LuaApp.Constants)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local AEAssetCard = Roact.PureComponent:extend("AEAssetCard")
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")

local BUTTONS_PER_ROW = 4
local View = {
	[DeviceOrientationMode.Portrait] = {
		GRID_PADDING = 6,
		LEADING_OFFSET = 10,
	},

	[DeviceOrientationMode.Landscape] = {
		GRID_PADDING = 12,
		LEADING_OFFSET = 11,
	}
}

View.getAssetCardY = {
	[DeviceOrientationMode.Portrait] = function(index, deviceOrientation, assetButtonSize)
		local row = math.floor((index - 1) / BUTTONS_PER_ROW) + 1
		local rowHeight = assetButtonSize + View[deviceOrientation].GRID_PADDING
		return (row - 1) * rowHeight + View[deviceOrientation].LEADING_OFFSET
	end,

	[DeviceOrientationMode.Landscape] = function(index, deviceOrientation, assetButtonSize)
		local row = math.floor((index - 1) / BUTTONS_PER_ROW) + 1
		local rowHeight = assetButtonSize + View[deviceOrientation].GRID_PADDING
		return (row - 1) * rowHeight + View[deviceOrientation].LEADING_OFFSET
	end,
}

function AEAssetCard:init()
	local image = Instance.new("ImageLabel")
	image.Image = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-item selector-16px corner.png"
	image.Position = UDim2.new(0, -7, 0, -7)
	image.Size = UDim2.new(1, 14, 1, 14)
	image.BackgroundTransparency = 1
	image.ScaleType = Enum.ScaleType.Slice
	image.SliceCenter = Rect.new(51, 51, 103, 103)
	self.selectionImageObject = image
end

function AEAssetCard:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEAssetCard:getThemeInfo(deviceOrientation, themeName)
	local recommendedAsset = self.props.recommendedAsset
	local isOutfit = self.props.isOutfit
	local index = self.props.index
	local cardImage = self.props.cardImage
	local positionOverride = self.props.positionOverride
	local assetId = self.props.assetId
	local assetButtonSize = self.props.assetButtonSize
	local activateFunction = self.props.activateFunction
	local longPressFunction = self.props.longPressFunction
	local column = ((index - 1) % themeInfo.OrientationTheme.ButtonsPerRow) + 1

	local isSelected, assetBorderMaskImage, backgroundImage
	if recommendedAsset then
		isSelected = false
	else
		isSelected = self.props.checkIfWearingAsset(assetId, isOutfit)
	end

	local equippedBorderConsole = nil
	if AEUtils.gamepadNavigationEnabled() then
		if recommendedAsset then
			assetBorderMaskImage = themeInfo.OrientationTheme.AssetBorderMask.ImageNotOwned
			backgroundImage = themeInfo.OrientationTheme.ButtonBackground.ImageUnavailable
		else
			backgroundImage = themeInfo.OrientationTheme.ButtonBackground.ImageAvailable
			if isSelected then
				assetBorderMaskImage = themeInfo.OrientationTheme.AssetBorderMask.ImageEquipped
			else
				assetBorderMaskImage = themeInfo.OrientationTheme.AssetBorderMask.ImageOwned
			end
		end

		equippedBorderConsole = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = assetBorderMaskImage,
			ZIndex = 3,
		})
	end

	local backgroundColor = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BackgroundColor or Constants.Color.WHITE

	local assetCardY = themeInfo.OrientationTheme.getAssetCardY(index, assetButtonSize)
	local gridPadding = themeInfo.OrientationTheme.GridPadding
	local AssetButton = Roact.createElement("ImageButton", {
		AutoButtonColor = false,
		BorderColor3 = Color3.fromRGB(208, 208, 208),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, assetButtonSize, 0, assetButtonSize),
		Position = positionOverride or UDim2.new(0, gridPadding + (column - 1)
			* (assetButtonSize + gridPadding) - 3, 0, assetCardY),
		SelectionImageObject = self.selectionImageObject,
		[Roact.Event.Activated] = activateFunction,
		[Roact.Event.TouchLongPress] = FFlagChinaLicensingApp and function() end or longPressFunction,
	}, {
		ButtonBackground = Roact.createElement("ImageLabel", {
			BackgroundTransparency = themeInfo.OrientationTheme.ButtonBackground.BackgroundTransparency,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(16, 16, 17, 17),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = backgroundColor,
			Image = backgroundImage or "",
		}),

		ImageLabel = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = cardImage,
			Size = UDim2.new(1, 0, 1, 0)
		}),

		SelectionFrame = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			ZIndex = 2,
			Visible = isSelected,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Image = themeInfo.OrientationTheme.SelectionFrame.Image,
			ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.EquippedFrameColor
				or Color3.fromRGB(255, 255, 255),
			ScaleType = themeInfo.OrientationTheme.SelectionFrame.ScaleType,
			SliceCenter = themeInfo.OrientationTheme.SelectionFrame.SliceCenter,
			BorderSizePixel = 0,
		}),
		Corner = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			ZIndex = 2,
			Visible = not AEUtils.gamepadNavigationEnabled() and isSelected,
			BackgroundTransparency = 1,
			Position = FFlagAvatarEditorEnableThemes and UDim2.new(.75, 0, 0, 0) or UDim2.new(.75, -2, 0, 2),
			Size = UDim2.new(.25, 0, .25, 0),
			ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.EquippedFrameColor
				or Color3.fromRGB(255, 255, 255),
			Image = themeInfo.OrientationTheme.Corner.Image,
		}),
		MoveSelection = themeInfo.OrientationTheme.Sound,
		EquippedBorderConsole = equippedBorderConsole,
	})

	return AssetButton
end

return AEAssetCard