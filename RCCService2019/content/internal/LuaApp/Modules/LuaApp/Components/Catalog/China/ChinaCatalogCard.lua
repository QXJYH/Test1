local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)
local LocalizedTextButton = require(Modules.LuaApp.Components.LocalizedTextButton)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local Constants = require(Modules.LuaApp.Constants)

-- Components
local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)
local ShimmerPanel = require(Modules.LuaApp.Components.ShimmerPanel)
local FitImageTextFrame = require(Modules.LuaApp.Components.FitImageTextFrame)

-- Constants
local TEXT_LINE_COUNT = 2
local DEFAULT_ITEM_ICON = Constants.DEFAULT_GAME_ICON -- TODO: replace with what UX team gives us
local ROBUX_ICON = "LuaApp/icons/robux_white"

local LARGE_CARD_WIDTH = 148
local MEDIUM_CARD_WIDTH = 100

local GameCardFooterLayout = {
	[Constants.GameCardLayoutType.Small] = {
		OuterMargin = 3,
		InnerMargin = 3,
		TextSize = 16,
		IconSize = 14,
		IconPadding = 2,
	},
	[Constants.GameCardLayoutType.Medium] = {
		OuterMargin = 6,
		InnerMargin = 3,
		TextSize = 16,
		IconSize = 14,
		IconPadding = 2,
	},
	[Constants.GameCardLayoutType.Large] = {
		OuterMargin = 6,
		InnerMargin = 3,
		TextSize = 22,
		IconSize = 18,
		IconPadding = 5,
	},
}

local ChinaCatalogCard = Roact.PureComponent:extend("ChinaCatalogCard")

function ChinaCatalogCard:init()
	self.onActivated = function(itemId, itemType)
		self.props.navigateDown({ name = AppPage.ChinaBundleModal,
			detail = itemId,
			extraProps = { itemType = itemType},
		})
	end
	self.defaultProps = {
		itemInfo = {},
		thumbnail = "",
		position = UDim2.new(0,0,0,0),
	}
end

local function getLayoutInfo(layoutType, size)
	local layoutInfo = Cryo.Dictionary.join(GameCardFooterLayout[layoutType])
	layoutInfo.TitleHeight = layoutInfo.TextSize
	layoutInfo.FooterHeight = size.Y - size.X
	layoutInfo.FooterContentWidth = size.X - layoutInfo.OuterMargin * 2
	return layoutInfo
end

local function getImageProps(image, layoutInfo, themeInfo)
	return {
		Size = UDim2.new(0, layoutInfo.IconSize, 0, layoutInfo.IconSize),
		Image = image,
		ImageColor3 = themeInfo.Color,
		ImageTransparency = themeInfo.Transparency,
	}
end

local function getTextProps(text, layoutInfo, themeInfo)
	return {
		Text = text,
		Font = themeInfo.Font,
		TextColor3 = themeInfo.Color,
		TextTransparency = themeInfo.Transparency,
		TextSize = layoutInfo.TextSize,
	}
end

local function getLayoutType(width)
	if width >= LARGE_CARD_WIDTH then
		return Constants.GameCardLayoutType.Large
	elseif width >= MEDIUM_CARD_WIDTH then
		return Constants.GameCardLayoutType.Medium
	else
		return Constants.GameCardLayoutType.Small
	end
end

local function getHeight(width, size)
	local layoutType = getLayoutType(size.X)
	local layoutInfo = getLayoutInfo(layoutType, size);
	return width + layoutInfo.OuterMargin + layoutInfo.TextSize * TEXT_LINE_COUNT
end

function ChinaCatalogCard:render()
	local deviceOrientation = self.props.deviceOrientation
	local size = self.props.Size
	local position = self.props.Positon or self.defaultProps.position
	local theme = self._context.ChinaCatalogTheme.ChinaCatalogCard:getThemeInfo(
		deviceOrientation, Constants.Themes.Dark) or nil
	local footerHeight = size.Y - size.X
	local thumbnail = self.props.thumbnail or self.defaultProps.thumbnail
	local itemInfo = self.props.itemInfo or self.defaultProps.itemInfo
	local layoutType = getLayoutType(size.X)
	local layoutInfo = getLayoutInfo(layoutType, size);
	local price = itemInfo.priceInRobux
	local priceComponent = nil

	if price == nil then
		priceComponent = Roact.createElement(ShimmerPanel, {
			Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
			LayoutOrder = 2,
		})
	else
		if price == 0 then
			priceComponent = Roact.createElement(LocalizedTextButton, {
				BackgroundTransparency = 1,
				Font = theme.ColorTheme.Price.Font,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
				Text = "Feature.Catalog.LabelFree",
				TextSize = layoutInfo.TextSize,
				TextColor3 = theme.ColorTheme.Price.Color,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
		else
			priceComponent = Roact.createElement(FitImageTextFrame, {
				LayoutOrder = 2,
				padding = layoutInfo.IconPadding,
				Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
				imageProps = getImageProps(ROBUX_ICON, layoutInfo, theme.ColorTheme.Price),
				textProps = getTextProps(price, layoutInfo, theme.ColorTheme.Price),
			})
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0,size.X,0,size.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = self.props.LayoutOrder,
	}, {
		CatalogButton = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			ZIndex = 2,
			[Roact.Event.Activated] = function(...) return self.onActivated(self.props.itemId, self.props.itemType) end,
		}, {
			Icon = Roact.createElement(LoadableImage, {
				Image = thumbnail,
				Size = UDim2.new(0,size.X,0,size.X),
				Position = position,
				BackgroundTransparency = theme.ColorTheme.Background.Transparency,
				BackgroundColor3 = theme.ColorTheme.Background.Color,
				BorderSizePixel = 0,
				loadingImage = DEFAULT_ITEM_ICON,
				useShimmerAnimationWhileLoading = true,
			}),
			Footer = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, footerHeight),
				Position = UDim2.new(0, 0, 0, size.X),
				BorderSizePixel = 0,
				BackgroundColor3 = theme.ColorTheme.Footer.Color,
				BackgroundTransparency = theme.ColorTheme.Footer.Transparency,
				ZIndex = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, layoutInfo.InnerMargin),
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, layoutInfo.OuterMargin),
					PaddingRight = UDim.new(0, layoutInfo.OuterMargin),
					PaddingTop = UDim.new(0, layoutInfo.OuterMargin),
				}),
				Title = (itemInfo.name == nil) and Roact.createElement(ShimmerPanel, {
					Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
					LayoutOrder = 1,
				}) or Roact.createElement("TextLabel", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextSize = layoutInfo.TextSize,
					TextColor3 = theme.ColorTheme.Title.Color,
					Font = theme.ColorTheme.Title.Font,
					Text = itemInfo.name,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),
				Price = priceComponent,
			}),
		})
	})
end

ChinaCatalogCard = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			assets = state.CatalogAppReducer.Assets[tostring(props.itemId)],
			bundleInfo = state.CatalogAppReducer.Bundles[tostring(props.itemId)],
			assetInfo = state.AEAppReducer.AEAssetInfo[props.itemId],
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(ChinaCatalogCard)


ChinaCatalogCard.getHeight = getHeight
return ChinaCatalogCard