local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)

local FitChildren = require(Modules.LuaApp.FitChildren)
local ItemListLayout = require(Modules.LuaApp.Components.Generic.ItemListLayout)
local SwipeableDrawer = require(Modules.LuaApp.Components.Generic.SwipeableDrawer)
local MyRobuxArea = require(Modules.LuaApp.Components.Home.MyRobuxArea)
local SignOutButton = require(Modules.LuaApp.Components.Home.SignOutButton)
local ChallengesWidget = require(Modules.LuaApp.Components.Home.ChallengesWidget)
local AvatarWidget = require(Modules.LuaApp.Components.Home.AvatarWidget)
local CatalogWidget = require(Modules.LuaApp.Components.Home.CatalogWidget)
local UnreadChatWidget = require(Modules.LuaApp.Components.Chat.Widgets.UnreadChatWidget)
local TermsAndPrivacyButtons = require(Modules.LuaApp.Components.Home.TermsAndPrivacyButtons)
local VersionTextWidget = require(Modules.LuaApp.Components.Home.VersionTextWidget)
local ScrollingFrameWithExternalScrollBar = require(
	Modules.LuaApp.Components.Generic.ScrollingFrameWithExternalScrollBar)

local WIDGET_VERTICAL_GUTTER = 10
local PANEL_FIT_AXIS = FitChildren.FitAxis.Height
local SCROLL_BAR_THICKNESS = 8
local SCROLL_BAR_CONTENT_GAP = 5
local FOOTER_TEXT_SIZE = 12
local FOOTER_TEXT_SIZE_CHINESE = 16
local FOOTER_TEXT_HEIGHT = 17
local FOOTER_TEXT_HEIGHT_CHINESE = 22

local HomePagePanel = Roact.PureComponent:extend("HomePagePanel")

HomePagePanel.defaultProps = {
	panelVerticalOffset = 0,
}

function HomePagePanel:render()
	local theme = self._context.AppTheme
	local localization = self.props.localization
	local zIndex = self.props.zIndex
	local position = self.props.position
	local anchorPoint = self.props.anchorPoint
	local width = self.props.width
	local height = self.props.height
	local panelVerticalOffset = self.props.panelVerticalOffset
	local bottomPadding = self.props.bottomPadding

	local hasVerticalOffset = panelVerticalOffset > 0
	local locale = localization:GetLocale()

	local footerTextSize = FOOTER_TEXT_SIZE
	local footerTextHeight = FOOTER_TEXT_HEIGHT
	if locale and (locale == "zh-cn" or locale == "zh-tw") then
		footerTextSize = FOOTER_TEXT_SIZE_CHINESE
		footerTextHeight = FOOTER_TEXT_HEIGHT_CHINESE
	end

	local panelContent = {
		-- Created to make FitChildren work.
		ListLayout = Roact.createElement("UIListLayout"),
		Padding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, bottomPadding),
		}),
		Widgets = Roact.createElement(ItemListLayout, {
			size = UDim2.new(0, width, 0, 0),
			Padding = UDim.new(0, WIDGET_VERTICAL_GUTTER),
			fitAxis = PANEL_FIT_AXIS,
			renderItemList = {
				Roact.createElement(MyRobuxArea),
				Roact.createElement(ChallengesWidget, {
					renderWidth = width,
				}),
				Roact.createElement(AvatarWidget, {
					renderWidth = width,
				}),
				Roact.createElement(CatalogWidget, {
					renderWidth = width,
				}),
				Roact.createElement(UnreadChatWidget),
				Roact.createElement(SignOutButton),
				Roact.createElement(TermsAndPrivacyButtons, {
					TextSize = footerTextSize,
					textHeight = footerTextHeight,
				}),
				Roact.createElement(VersionTextWidget, {
					TextSize = footerTextSize,
					textHeight = footerTextHeight,
				}),
			},
		}),
	}

	return Roact.createElement("Frame", {
		ZIndex = zIndex,
		Size = UDim2.new(0, width, 0, height),
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	}, {
		Panel = hasVerticalOffset and Roact.createElement(SwipeableDrawer, {
			Size = UDim2.new(1, 0, 1, 0),
			startPosition = panelVerticalOffset,
			containerHeight = height,
		}, panelContent) or Roact.createElement(ScrollingFrameWithExternalScrollBar, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = SCROLL_BAR_THICKNESS,
			scrollBarPositionOffsetX = SCROLL_BAR_CONTENT_GAP,
			onlyRenderScrollBarOnHover = true,
			ScrollBarImageColor3 = theme.ScrollingFrameWithScrollBar.ScrollBar.Color,
			ScrollBarImageTransparency = theme.ScrollingFrameWithScrollBar.ScrollBar.Transparency,
			ClipsDescendants = false,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, panelContent)
	})
end

HomePagePanel = RoactServices.connect({
	localization = RoactLocalization,
})(HomePagePanel)

return HomePagePanel