local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local Constants = require(Modules.LuaApp.Constants)
local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local HomePagePanel = require(Modules.LuaApp.Components.Home.HomePagePanel)
local BackgroundWithMask = require(Modules.LuaApp.Components.Home.BackgroundWithMask)
local UserAvatar = require(Modules.LuaApp.Components.Home.UserAvatar)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local FFlagLuaAppHomeIconPolicy = settings():GetFFlag("LuaAppHomeIconPolicy")

local LOGO_SIZE = Constants.HomePageLogoSize
local LOGO_IMAGE = nil

local PADDING_TOP_COMPACT_VIEW = 20
local PADDING_LEFT_COMPACT_VIEW = 20
local PADDING_RIGHT_COMPACT_VIEW = 20

local PADDING_TOP_WIDE_VIEW = 40
local PADDING_LEFT_WIDE_VIEW = 40
local PADDING_RIGHT_WIDE_VIEW = 20

local PANEL_WIDTH_WIDE_VIEW = 375
local PANEL_BOTTOM_PADDING_WIDE = 53
local PANEL_BOTTOM_PADDING_COMPACT = 28

local AVATAR_HEIGHT_RATIO_SMALL = 0.66
local AVATAR_HEIGHT_RATIO_LARGE = 0.75

local zIndexTable = {
	Logo = 1,
	Panel = 2,
}

local HomePageWithAvatarAndWidget = Roact.PureComponent:extend("HomePageWithAvatarAndWidget")

function HomePageWithAvatarAndWidget:init()
	self.state = {
		contentSize = Vector2.new(0, 0),
	}

	self.isMounted = false

	self.onAbsoluteSizeChanged = function(rbx)
		local newAbsoluteSize = rbx.AbsoluteSize
		if self.state.contentSize ~= newAbsoluteSize and
			newAbsoluteSize.X > 0 and newAbsoluteSize.Y > 0 then
			-- Spawn since setstate can be triggered while a component is being reified or reconciled.
			-- This can be fixed with event suspension in new reconciler.
			spawn(function()
				if self.isMounted then
					self:setState({
						contentSize = newAbsoluteSize
					})
				end
			end)
		end
	end
end

function HomePageWithAvatarAndWidget:didMount()
	self.isMounted = true
end

function HomePageWithAvatarAndWidget:willUnmount()
	self.isMounted = false
end

function HomePageWithAvatarAndWidget:render()
	local theme = self._context.AppTheme

	local formFactor = self.props.formFactor
	local screenSize = self.props.screenSize
	local contentSize = self.state.contentSize

	local panelVerticalOffset = 0

	local paddingTop = 0
	local paddingLeft = 0
	local paddingRight = 0

	local panelWidth = PANEL_WIDTH_WIDE_VIEW
	local panelHeight = contentSize.Y
	local panelPosition = UDim2.new(1, 0, 1, 0)
	local panelAnchorPoint = Vector2.new(1, 1)
	local panelBottomPadding = 0
	local avatarPosition
	local avatarAnchorPoint
	local avatarSizeConstraint
	local avatarSize
	local avatarMaxTextWidth
	local pageContents

	local homeIcon = self.props.homeIcon

	if formFactor == FormFactor.COMPACT then
		paddingTop = PADDING_TOP_COMPACT_VIEW
		paddingLeft = PADDING_LEFT_COMPACT_VIEW
		paddingRight = PADDING_RIGHT_COMPACT_VIEW

		panelWidth = contentSize.X
		panelAnchorPoint = Vector2.new(0, 0)
		panelPosition = UDim2.new(0, 0, 0, 0)
		panelVerticalOffset = screenSize.X + LOGO_SIZE.Y
		panelBottomPadding = PANEL_BOTTOM_PADDING_COMPACT

		avatarPosition = UDim2.new(0, 0, 0, LOGO_SIZE.Y)
		avatarAnchorPoint = Vector2.new(0, 0)
		avatarSizeConstraint = Enum.SizeConstraint.RelativeXX
		avatarMaxTextWidth = contentSize.X
		avatarSize = UDim2.new(1, 0, 1, 0)
	else
		paddingTop = PADDING_TOP_WIDE_VIEW
		paddingLeft = PADDING_LEFT_WIDE_VIEW
		paddingRight = PADDING_RIGHT_WIDE_VIEW

		panelBottomPadding = PANEL_BOTTOM_PADDING_WIDE
		if contentSize.X <= PANEL_WIDTH_WIDE_VIEW * 2 then
			panelWidth = contentSize.X / 2
		end

		avatarPosition = UDim2.new(0.5, - panelWidth / 2, 0.5, 0)
		avatarAnchorPoint = Vector2.new(0.5, 0.5)
		avatarSizeConstraint = Enum.SizeConstraint.RelativeYY
		avatarMaxTextWidth = contentSize.X - panelWidth

		if screenSize.X <= screenSize.Y then
			avatarSize = UDim2.new(1, 0, AVATAR_HEIGHT_RATIO_SMALL, 0)
		else
			avatarSize = UDim2.new(1, 0, AVATAR_HEIGHT_RATIO_LARGE, 0)
		end
	end

	-- don't show contents until render has calculated the actual component size
	if contentSize.X > 0 and contentSize.Y > 0 then
		pageContents = {
			Logo = Roact.createElement(ImageSetLabel, {
				ZIndex = zIndexTable.Logo,
				Size = UDim2.new(0, LOGO_SIZE.X, 0, LOGO_SIZE.Y),
				BackgroundTransparency = 1,
				Image = homeIcon,
			}),
			UserAvatar = Roact.createElement(UserAvatar, {
				size = avatarSize,
				position = avatarPosition,
				anchorPoint = avatarAnchorPoint,
				sizeConstraint = avatarSizeConstraint,
				maxTextWidth = avatarMaxTextWidth,
			}),
			HomePagePanel = Roact.createElement(HomePagePanel, {
				zIndex = zIndexTable.Panel,
				width = panelWidth,
				height = panelHeight,
				position = panelPosition,
				panelVerticalOffset = panelVerticalOffset,
				anchorPoint = panelAnchorPoint,
				bottomPadding = panelBottomPadding,
			}),
		}
	else
		pageContents = nil
	end

	return Roact.createElement(FullscreenPageWithSafeArea, {
		BackgroundColor3 = theme.Main.Background.Color,
		includeStatusBar = true,
		renderFullscreenBackground = function(safeAreaPositionY)
			return Roact.createElement(BackgroundWithMask, {
				safeAreaPositionY = safeAreaPositionY,
			})
		end,
	}, {
		Contents = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}, {
			-- MOBLUAPP-1273: UIListLayout and additional layer of Frame was added to go around
			-- the issue where the padding is not correctly applied to its FitChildren child.
			-- This is to be removed when MOBLUAPP-1273 is addressed.
			ListLayout = Roact.createElement("UIListLayout"),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, paddingTop),
				PaddingLeft = UDim.new(0, paddingLeft),
				PaddingRight = UDim.new(0, paddingRight),
			}),
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
			}, pageContents),
		}),
	})
end

HomePageWithAvatarAndWidget = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
		}
	end
)(HomePageWithAvatarAndWidget)

if FFlagLuaAppHomeIconPolicy then
	HomePageWithAvatarAndWidget = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			homeIcon = appPolicy.getHomeIcon() or nil,
		}
	end)(HomePageWithAvatarAndWidget)
end

return HomePageWithAvatarAndWidget
