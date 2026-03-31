local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local Constants = require(Modules.LuaApp.Constants)
local getGameCardSize = require(Modules.LuaApp.getGameCardSize)

local GridView = require(Modules.LuaApp.Components.Generic.GridView)
local GameCard = require(Modules.LuaApp.Components.Games.GameCard)
local AppGameTile = require(Modules.LuaApp.Components.Games.AppGameTile)

local CONTAINER_PADDING = Constants.GAME_GRID_PADDING
local CARD_MARGIN = Constants.GAME_GRID_CHILD_PADDING

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

local GameGrid = Roact.PureComponent:extend("GameGrid")

GameGrid.defaultProps = {
	friendFooterEnabled = false,
}

function GameGrid:renderItem(entry, cardSize, index)
	local friendFooterEnabled = self.props.friendFooterEnabled

	local reportGameDetailOpened = self.props.reportGameDetailOpened
	local reportQuickGameLaunch = self.props.reportQuickGameLaunch
	if useNewAppStyle then
		return Roact.createElement(AppGameTile, {
			layoutOrder = index,
			entry = entry,
			size = cardSize,
			index = index,
			reportGameDetailOpened = reportGameDetailOpened,
			reportQuickGameLaunch = reportQuickGameLaunch,
		})
	else
		return Roact.createElement(GameCard, {
			layoutOrder = index,
			entry = entry,
			size = cardSize,
			index = index,
			friendFooterEnabled = friendFooterEnabled,
			reportGameDetailOpened = reportGameDetailOpened,
			reportQuickGameLaunch = reportQuickGameLaunch,
		})
	end
end

function GameGrid:render()
	local entries = self.props.entries
	local layoutOrder = self.props.LayoutOrder
	local numberOfRowsToShow = self.props.numberOfRowsToShow
	local windowSize = self.props.windowSize

	local cardSize, _ = getGameCardSize(windowSize.X, CONTAINER_PADDING * 2, CARD_MARGIN, 0)

	return Roact.createElement(GridView, {
		layoutOrder = layoutOrder,
		items = entries,
		renderItem = function(...) return self:renderItem(...) end,
		windowAbsoluteSize = windowSize,
		itemAbsoluteSize = cardSize,
		cellPaddingOffset = Vector2.new(CARD_MARGIN, CARD_MARGIN),
		numberOfRowsToShow = numberOfRowsToShow,
	})
end

return GameGrid