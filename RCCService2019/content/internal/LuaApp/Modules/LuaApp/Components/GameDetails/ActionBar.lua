local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local Constants = require(Modules.LuaApp.Constants)

local PlayButtonContainer = require(Modules.LuaApp.Components.PlayButtonContainer)
local GameDetailMoreButton = require(Modules.LuaApp.Components.GameDetails.GameDetailMoreButton)

local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)

local ACTION_BAR_HEIGHT = Constants.GameDetails.ActionBarHeight
local GRADIENT_HEIGHT = Constants.GameDetails.ActionBarGradientHeight

local MORE_BUTTON_WIDTH = ACTION_BAR_HEIGHT
local MORE_BUTTON_PLAY_BUTTON_GAP = 10

local GRADIENT_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/gradient_0_100.png"

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local ActionBar = Roact.PureComponent:extend("ActionBar")

ActionBar.defaultProps = {
	bottomPadding = 0,
	showMorePage = true,
}

function ActionBar:render()
	local theme = self._context.AppTheme
	local zIndex = self.props.ZIndex
	local leftPadding = self.props.leftPadding
	local rightPadding = self.props.rightPadding
	local bottomPadding = self.props.bottomPadding
	local containerWidth = self.props.containerWidth
	local universeId = self.props.universeId
	local showMorePage = self.props.showMorePage

	local moreButtonWidth = showMorePage and MORE_BUTTON_WIDTH or 0
	local moreButtonPlayButtonGap = showMorePage and MORE_BUTTON_PLAY_BUTTON_GAP or 0

	local actionBarHeightWithPadding = ACTION_BAR_HEIGHT + bottomPadding
	local totalHeight = actionBarHeightWithPadding + GRADIENT_HEIGHT

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, totalHeight),
		Position = UDim2.new(0, 0, 1, -totalHeight),
		BackgroundTransparency = 1,
		ZIndex = zIndex,
	}, {
		ActionBar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, actionBarHeightWithPadding),
			Position = UDim2.new(0, 0, 1, -actionBarHeightWithPadding),
			BackgroundColor3 = theme.Color.Background,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, moreButtonPlayButtonGap),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, leftPadding),
				PaddingRight = UDim.new(0, rightPadding),
				PaddingBottom = UDim.new(0, bottomPadding),
			}),
			MoreButton = showMorePage and Roact.createElement(GameDetailMoreButton, {
				LayoutOrder = 1,
				universeId = universeId,
				leftPadding = leftPadding,
				rightPadding = leftPadding,
				containerWidth = containerWidth,
			}),
			PlayButtonContainer = Roact.createElement(PlayButtonContainer, {
				Size = UDim2.new(1, - moreButtonWidth - moreButtonPlayButtonGap, 1, 0),
				LayoutOrder = 2,
				Font = theme.GameDetails.Text.Font,
				universeId = universeId,
			}),
		}),
		Gradient = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 0, GRADIENT_HEIGHT),
			Position = UDim2.new(0, 0, 1, -actionBarHeightWithPadding),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Image = GRADIENT_IMAGE,
			ImageColor3 = theme.Color.Background,
		})
	})
end

if FFlagLuaAppPolicyRoactConnector then
	ActionBar = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			showMorePage = appPolicy.getGameDetailsMorePage(),
		}
	end)(ActionBar)
else
	ActionBar = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			showMorePage = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.GameDetailsMorePage),
		}
	end)(ActionBar)
end

return ActionBar
