local GuiService = game:GetService("GuiService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AEWebApi = require(Modules.LuaApp.Components.Avatar.AEWebApi)
local AEAssetCard = require(Modules.LuaApp.Components.Avatar.UI.AEAssetCard)
local AEGetRecommendedAssets = require(Modules.LuaApp.Thunks.AEThunks.AEGetRecommendedAssets)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")

local AERecommendedFrame = Roact.PureComponent:extend("AERecommendedFrame")
local View = {
	[DeviceOrientationMode.Portrait] = {
		SHOP_BUTTON_POSITION_X = -100,
		LABEL_FONT = Enum.Font.SourceSansLight,
		LABEL_COLOR = Color3.fromRGB(65, 78, 89),
	},

	[DeviceOrientationMode.Landscape] = {
		SHOP_BUTTON_POSITION_X = -88,
		LABEL_FONT = Enum.Font.SourceSans,
		LABEL_COLOR = Color3.new(.9, .9, .9),
	},
}

function AERecommendedFrame:makeShopPressFunction()
	local page = self.props.page
	return function()
		local url = "https://www.roblox.com" .. (page.shopUrl or "/catalog")
		GuiService:OpenNativeOverlay( "Catalog", url )
	end
end

function AERecommendedFrame:shopInCatalogButtonUI()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
			self._context.AvatarEditorTheme.AEShopButton:getThemeInfo(nil, themeName) or nil
	local pressFunction = self:makeShopPressFunction()
	local imageInfo = {}

	if FFlagAvatarEditorEnableThemes then
		imageInfo.Image = nil
		imageInfo.ScaleType = nil
		imageInfo.SliceCenter = nil
	else
		imageInfo.Image = 'rbxasset://textures/AvatarEditorImages/btn.png'
		imageInfo.ScaleType = Enum.ScaleType.Slice
		imageInfo.SliceCenter = Rect.new(3, 3, 4, 4)
	end

	local ShopInCatalogButton = Roact.createElement('ImageButton', {
		AnchorPoint = Vector2.new(.5, 0),
		Position = UDim2.new(.5, 0, .5, 0),
		Size = UDim2.new(0, 160, 0, 36),
		ZIndex = 5,
		BackgroundTransparency = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BackgroundTransparency or 1,
		BackgroundColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BorderSizePixel or 1,
		BorderColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BorderColor or Color3.fromRGB(27, 42, 53),
		Image = imageInfo.Image,
		ScaleType = imageInfo.ScaleType,
		SliceCenter = imageInfo.SliceCenter,
		[Roact.Event.Activated] = pressFunction,
	}, {
		TextLabel = Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			BackgroundTransparency = 1,
			Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
			Text = 'Feature.Avatar.Action.ShopInCatalog',
			TextSize = FFlagAvatarEditorGothamFont and 20 or 22,
			TextColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TextColor or Color3.new(1,1,1),
			TextScaled = false,
			TextStrokeTransparency = 1,
		})
	})
	return ShopInCatalogButton
end

function AERecommendedFrame:shopNowButtonUI()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
			self._context.AvatarEditorTheme.AEShopButton:getThemeInfo(deviceOrientation, themeName) or nil
	local recommendedYPosition = self.props.recommendedYPosition
	local pressFunction = self:makeShopPressFunction()
	local imageInfo = {}

	if FFlagAvatarEditorEnableThemes then
		imageInfo.Image = nil
		imageInfo.ScaleType = nil
		imageInfo.SliceCenter = nil
	else
		imageInfo.Image = 'rbxasset://textures/AvatarEditorImages/btn.png'
		imageInfo.ScaleType = Enum.ScaleType.Slice
		imageInfo.SliceCenter = Rect.new(3, 3, 4, 4)
	end

	local ShopNowButton = Roact.createElement('ImageButton', {
		Position = UDim2.new(1, View[deviceOrientation].SHOP_BUTTON_POSITION_X, 0, recommendedYPosition - 3),
		Size = UDim2.new(0, 85, 0, 26),
		ZIndex = 5,
		BackgroundTransparency = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BackgroundTransparency or 1,
		BackgroundColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BorderSizePixel or 0,
		BorderColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BorderColor or Color3.fromRGB(27, 42, 53),
		Image = imageInfo.Image,
		ScaleType = imageInfo.ScaleType,
		SliceCenter = imageInfo.SliceCenter,
		Visible = true,
		[Roact.Event.Activated] = pressFunction,
	}, {
		Roact.createElement(LocalizedTextLabel, {
			Position = UDim2.new(0, 0, 0, -1),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
			Text = 'Feature.Avatar.Action.ShopNow',
			TextSize = FFlagAvatarEditorGothamFont and 16 or 18,
			TextColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TextColor or Color3.new(1,1,1),
			TextScaled = false,
			TextStrokeTransparency = 1,
		})
	})
	return ShopNowButton
end

function AERecommendedFrame:recommendedLabelUI()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(nil, themeName)
	local deviceOrientation = self.props.deviceOrientation
	local recommendedYPosition = self.props.recommendedYPosition

	local RecommendedLabel = Roact.createElement(LocalizedTextLabel, {
		Position = UDim2.new(0, 7, 0, recommendedYPosition - 2),
		Size = UDim2.new(1, -14, 0, 25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or View[deviceOrientation].LABEL_FONT,
		FontSize = Enum.FontSize.Size18,
		Text = 'Feature.Avatar.Heading.Recommended',
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.PageLabelTextColor or View[deviceOrientation].LABEL_COLOR,
		ZIndex = 3,
	})
	return RecommendedLabel
end

function AERecommendedFrame:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEAssetCard:getThemeInfo(deviceOrientation, themeName)
	local scrollingFrame = self.props.scrollingFrame
	local assetsToRender = self.props.assetsToRender
	local page = self.props.page
	local recommendedYPosition = self.props.recommendedYPosition
	local assetButtonSize = self.props.assetButtonSize
	local assets = {}
	local shopInCatalogButton = nil
	local recommendedLabel = nil
	local shopNowButton = nil
	local noAssets = #assetsToRender == 0
	local lastAssetCardY = recommendedYPosition - 5
	if noAssets then
		if not AEUtils.gamepadNavigationEnabled() then
			shopInCatalogButton = self:shopInCatalogButtonUI()
		end
	elseif not noAssets and page.shopUrl then
		recommendedLabel = self:recommendedLabelUI()
		shopNowButton = not AEUtils.gamepadNavigationEnabled() and self:shopNowButtonUI() or nil
		local recommendedAssets = self.props.recommendedAssets[page.assetTypeId]
		if not recommendedAssets and page.name ~= AEConstants.OUTFITS then
			self.props.getRecommendedAssets(page.assetTypeId)
		end
		if recommendedAssets and recommendedAssets.isValid then
			for i, itemData in pairs(recommendedAssets.data.Items) do
				if itemData and itemData.Item then
					-- Create card for recommended item
					local assetId = itemData.Item.AssetId

					local column = ((i - 1) % themeInfo.OrientationTheme.ButtonsPerRow) + 1
					local row = math.floor((i - 1) / themeInfo.OrientationTheme.ButtonsPerRow) + 1
					local rowHeight = assetButtonSize + themeInfo.OrientationTheme.GridPadding
					local yPos =  (row - 1) * rowHeight + recommendedYPosition
					local position = UDim2.new(0, themeInfo.OrientationTheme.GridPadding + (column - 1)
						* (assetButtonSize + themeInfo.OrientationTheme.GridPadding) - 3, 0, yPos + 30)

					local cardImage = AEUtils.getThumbnail(false, assetId)

					lastAssetCardY = position.Y.Offset + assetButtonSize + themeInfo.OrientationTheme.GridPadding
					local activateFunction = function(rbx)
						GuiService:OpenNativeOverlay("Catalog", AEWebApi.GetCatalogUrlForAsset(assetId))
					end

					assets[assetId] = Roact.createElement(AEAssetCard, {
						deviceOrientation = deviceOrientation,
						scrollingFrame = scrollingFrame,
						recommendedAsset = true,
						isOutfit = false,
						assetButtonSize = assetButtonSize,
						index = #assetsToRender + i,
						cardImage = cardImage,
						assetId = assetId,
						positionOverride = position,
						activateFunction = activateFunction,
					})
				end
			end
		end
	end

	if self.props.scrollingFrame then
		self.props.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, lastAssetCardY)
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		shopInCatalogButton = shopInCatalogButton,
		recommendedLabel = recommendedLabel,
		shopNowButton = shopNowButton,
		assets = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, assets),
	})
end

AERecommendedFrame = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			recommendedAssets = state.AEAppReducer.AECategory.AERecommendedAssets,
		}
	end,

	function(dispatch)
		return {
			getRecommendedAssets = function(assetTypeId)
				dispatch(AEGetRecommendedAssets(assetTypeId))
			end,
		}
	end
)(AERecommendedFrame)

return AERecommendedFrame
