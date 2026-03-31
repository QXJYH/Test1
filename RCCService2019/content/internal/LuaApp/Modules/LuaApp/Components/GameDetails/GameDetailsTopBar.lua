local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AppPage = require(Modules.LuaApp.AppPage)

local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)
local NavigateUp = require(Modules.LuaApp.Thunks.NavigateUp)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local NAVIGATION_BUTTON_LEFT_PADDING = 15
local NAVIGATION_BUTTON_SIZE = 36
local NAVIGATION_ICON_SIZE = 36
local CLOSE_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/close"
local BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"

local GameDetailsTopBar = Roact.PureComponent:extend("GameDetailsTopBar")

function GameDetailsTopBar:render()
	local theme = self._context.AppTheme
	local statusBarHeight = self.props.statusBarHeight
	local topBarHeight = self.props.topBarHeight
	local showCloseIcon = self.props.showCloseIcon

	local platform = self.props.platform
	local navigateBackOp = self.props.navigateBack
	if platform == Enum.Platform.Android then
		navigateBackOp = self.props.navigateUp
	end

	return Roact.createElement("Frame", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, topBarHeight),
		BackgroundTransparency = 1,
	}, {
		TouchFriendlyNavigationButton = Roact.createElement("TextButton", {
			Position = UDim2.new(0, NAVIGATION_BUTTON_LEFT_PADDING, 0, statusBarHeight),
			Size = UDim2.new(0, NAVIGATION_BUTTON_SIZE, 0, NAVIGATION_BUTTON_SIZE),
			BackgroundTransparency = 1,
			Text = "",
			[Roact.Event.Activated] = navigateBackOp,
		}, {
			NavigationButton = showCloseIcon and Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = CLOSE_BUTTON_IMAGE,
				ImageColor3 = theme.GameDetails.TopBar.Icon.Color,
				BackgroundTransparency = 1,
			}) or Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = BACK_BUTTON_IMAGE,
				ImageColor3 = theme.GameDetails.TopBar.Icon.Color,
				BackgroundTransparency = 1,
			}),
		}),
	})
end

local function selectShowCloseIcon(history)
	local currentRoute = history[#history]

	local numberOfGameDetailsPages = 0
	for index = 1, #currentRoute do
		if currentRoute[index].name == AppPage.GameDetail then
			numberOfGameDetailsPages = numberOfGameDetailsPages + 1

			if numberOfGameDetailsPages > 1 then
				break
			end
		end
	end

	-- Show the close icon if there are 1 or fewer pages, to accommodate
	-- the case where the current page is not yet part of the route history.
	return numberOfGameDetailsPages <= 1
end

GameDetailsTopBar = RoactRodux.UNSTABLE_connect2(
	function(state)
		return {
			platform = state.Platform,
			topBarHeight = state.TopBar.topBarHeight,
			statusBarHeight = state.TopBar.statusBarHeight,
			showCloseIcon = selectShowCloseIcon(state.Navigation.history),
		}
	end,
	function(dispatch)
		return {
			navigateBack = function()
				return dispatch(NavigateBack())
			end,
			navigateUp = function()
				return dispatch(NavigateUp())
			end,
		}
	end
)(GameDetailsTopBar)

return GameDetailsTopBar
