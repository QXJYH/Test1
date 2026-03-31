local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local GetGridLayoutSettings = require(Modules.LuaApp.GetGridLayoutSettings)

local AppPageWithNavigationBar = require(Modules.LuaApp.Components.Generic.AppPageWithNavigationBar)
local GridView = require(Modules.LuaApp.Components.Generic.GridView)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)

local GRID_CARD_PADDING = 10
local TEXT_SIZE = 16

local AppPageWithSmallGrid = Roact.PureComponent:extend("AppPageWithSmallGrid")

function AppPageWithSmallGrid:renderGrid(innerPadding, renderItem)
	local items = self.props.items
	local screenSize = self.props.screenSize
	local getHeight = self.props.getHeight

	if screenSize.X <= innerPadding * 2 or screenSize.Y <= 0 then
		return nil
	end

	local gridWidth = screenSize.X - innerPadding * 2
	local _, cardWidth = GetGridLayoutSettings.Small(gridWidth, GRID_CARD_PADDING)
	local cardHeight = getHeight(cardWidth)

	return Roact.createElement(GridView, {
		items = items,
		renderItem = renderItem,
		windowAbsoluteSize = Vector2.new(gridWidth, screenSize.Y),
		itemAbsoluteSize = Vector2.new(cardWidth, cardHeight),
		cellPaddingOffset = Vector2.new(GRID_CARD_PADDING, GRID_CARD_PADDING),
	})
end

function AppPageWithSmallGrid:render()
	local theme = self._context.AppTheme
	local title = self.props.title
	local dataStatus = self.props.dataStatus
	local onRetry = self.props.onRetry
	local renderItem = self.props.renderItem
	local items = self.props.items
	local noItemText = self.props.noItemText

	return Roact.createElement(AppPageWithNavigationBar, {
		title = title,
		dataStatus = dataStatus,
		onRetry = onRetry,
		renderContentOnLoading = function(innerPadding)
			return self:renderGrid(innerPadding, renderItem)
		end,
		renderContentOnLoaded = function(innerPadding)
			if #items == 0 then
				return Roact.createElement(LocalizedTextLabel, {
					Size = UDim2.new(1, 0, 0, TEXT_SIZE),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = noItemText,
					Font = theme.Main.BodyText.Font,
					TextColor3 = theme.Main.BodyText.Color,
					TextSize = TEXT_SIZE,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
			else
				return self:renderGrid(innerPadding, renderItem)
			end
		end,
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
		}
	end
)(AppPageWithSmallGrid)
