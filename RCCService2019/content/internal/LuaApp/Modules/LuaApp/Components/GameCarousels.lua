local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)

local GameCarousel = require(Modules.LuaApp.Components.Games.GameCarousel)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

local INTERNAL_PADDING
local CAROUSEL_PADDING_DIM = UDim.new(0, Constants.GAME_CAROUSEL_PADDING)
if useNewAppStyle then
	INTERNAL_PADDING = 24
else
	INTERNAL_PADDING = 15
end

local GameCarousels = Roact.PureComponent:extend("GameCarousels")

GameCarousels.defaultProps = {
	friendFooterEnabled = false,
}

function GameCarousels:render()
	local layoutOrder = self.props.LayoutOrder
	local sorts = self.props.sorts
	local analytics = self.props.analytics
	local friendFooterEnabled = self.props.friendFooterEnabled

	local padding
	if useNewAppStyle then
		padding = nil
	else
		padding = Roact.createElement("UIPadding", {
			PaddingTop = CAROUSEL_PADDING_DIM,
			PaddingBottom = CAROUSEL_PADDING_DIM,
			PaddingRight = CAROUSEL_PADDING_DIM,
			PaddingLeft = CAROUSEL_PADDING_DIM,
		})
	end

	local carousels = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, INTERNAL_PADDING),
		}),
		Padding = padding
	}

	for sortLayoutOrder, sortName in ipairs(sorts) do
		local key = sortName

		carousels[key] = Roact.createElement(GameCarousel, {
			sortName = sortName,
			LayoutOrder = sortLayoutOrder,
			analytics = analytics,
			friendFooterEnabled = friendFooterEnabled,
		})
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 0, 0),
		fitFields = { Size = FitChildren.FitAxis.Height },
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,

		[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
	}, carousels)
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			sorts = state.GameSortGroups[props.gameSortGroup].sorts
		}
	end
)(GameCarousels)