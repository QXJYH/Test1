local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local NavigationBar = require(Modules.LuaApp.Components.NavigationBar)
local ScrollingFrameWithExternalScrollBar = require(
	Modules.LuaApp.Components.Generic.ScrollingFrameWithExternalScrollBar)

local FFlagLuaAppHomeIconPolicy = settings():GetFFlag("LuaAppHomeIconPolicy")

local CONTENT_PADDING_TOP = 20
local SCROLL_BAR_THICKNESS = 8

local function getInnerPaddingSize(formFactor)
	if formFactor == FormFactor.COMPACT then
		return 20
	else
		return 40
	end
end

local function getNavBarSettings(formFactor)
	if formFactor == FormFactor.COMPACT then
		return {
			height = 44,
			titleTextSize = 23,
			buttonLeftPadding = 10,
		}
	else
		return {
			height = 105,
			titleTextSize = 42,
			buttonLeftPadding = 40,
			paddingTop = 40,
			paddingBottom = 20,
		}
	end
end

local AppPageWithNavigationBar = Roact.PureComponent:extend("AppPageWithNavigationBar")

AppPageWithNavigationBar.defaultProps = {
	dataStatus = RetrievalStatus.Done,
	topBuffer = 0,
}

function AppPageWithNavigationBar:renderScrollingArea(innerPadding, renderContent)
	local theme = self._context.AppTheme

	return Roact.createElement(ScrollingFrameWithExternalScrollBar, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		onlyRenderScrollBarOnHover = true,
		ScrollBarThickness = SCROLL_BAR_THICKNESS,
		scrollBarPositionOffsetX = -SCROLL_BAR_THICKNESS,
		ScrollBarImageColor3 = theme.ScrollingFrameWithScrollBar.ScrollBar.Color,
		ScrollBarImageTransparency = theme.ScrollingFrameWithScrollBar.ScrollBar.Transparency,
	}, {
		-- UIListLayout is a workaround to properly size children of a ScrollingFrame,
		--   as there looks to be an engine issue with it (CLIPLAYEREX-2680).
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, CONTENT_PADDING_TOP),
			PaddingLeft = UDim.new(0, innerPadding),
			PaddingRight = UDim.new(0, innerPadding),
		}),
		Content = renderContent(innerPadding),
	})
end

function AppPageWithNavigationBar:render()
	local theme = self._context.AppTheme
	local formFactor = self.props.formFactor
	local title = self.props.title
	local dataStatus = self.props.dataStatus
	local onRetry = self.props.onRetry
	local renderContentOnLoading = self.props.renderContentOnLoading
	local renderContentOnLoaded = self.props.renderContentOnLoaded
	local topBuffer = self.props.topBuffer
	local homeIcon = self.props.homeIcon

	local innerPadding = getInnerPaddingSize(formFactor)
	local navBarSettings = getNavBarSettings(formFactor)

	local contentSizeY = navBarSettings.height + topBuffer

	return Roact.createElement(FullscreenPageWithSafeArea, {
		BackgroundColor3 = theme.Color.Background,
		includeStatusBar = true,
	}, {
		TopBar = Roact.createElement(NavigationBar, {
			Size = UDim2.new(1, 0, 0, navBarSettings.height),
			icon = homeIcon,
			title = title,
			titleTextSize = navBarSettings.titleTextSize,
			buttonLeftPadding = navBarSettings.buttonLeftPadding,
			paddingTop = navBarSettings.paddingTop,
			paddingBottom = navBarSettings.paddingBottom,
		}),
		ContentArea = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -contentSizeY),
			Position = UDim2.new(0, 0, 0, contentSizeY),
			BackgroundTransparency = 1,
		}, {
			LoadingState = Roact.createElement(LoadingStateWrapper, {
				dataStatus = dataStatus,
				debugName = "AppPageWithNavBar-" .. (title or "NoTitle"),
				renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
				onRetry = onRetry,
				renderOnLoading = function()
					return self:renderScrollingArea(innerPadding, renderContentOnLoading)
				end,
				renderOnLoaded = function()
					return self:renderScrollingArea(innerPadding, renderContentOnLoaded)
				end,
			}),
		})
	})
end

AppPageWithNavigationBar = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
		}
	end
)(AppPageWithNavigationBar)

if FFlagLuaAppHomeIconPolicy then
	AppPageWithNavigationBar = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			homeIcon = props.icon or appPolicy.getHomeIcon() or nil,
		}
	end)(AppPageWithNavigationBar)
end

return AppPageWithNavigationBar
