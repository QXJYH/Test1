local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)

local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)

local GameGrid = require(Modules.LuaApp.Components.Games.GameGrid)
local SectionHeader = require(Modules.LuaApp.Components.SectionHeader)

local GAME_CAROUSEL_PADDING = Constants.GAME_CAROUSEL_PADDING
local GAME_GRID_PADDING = Constants.GAME_GRID_PADDING
local SECTION_HEADER_HEIGHT = Constants.SECTION_HEADER_HEIGHT
local SECTION_INNER_PADDING = 12
local TOP_SECTION_HEIGHT = SECTION_HEADER_HEIGHT + SECTION_INNER_PADDING
local EXTERNAL_PADDING = 24

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local HomeGameGrid = Roact.PureComponent:extend("HomeGameGrid")

HomeGameGrid.defaultProps = {
	numberOfRowsToShow = nil,
	friendFooterEnabled = false,
}

function HomeGameGrid:init()
	self.reportGameDetailOpened = function(index)
		local sort = self.props.sort
		local gameSortContents = self.props.gameSortContents
		local analytics = self.props.analytics

		local entries = gameSortContents.entries

		local itemsInSort = #entries
		local entry = entries[index]
		local placeId = entry.placeId
		local isAd = entry.isSponsored

		analytics.reportOpenGameDetail(
			placeId,
			sort.name,
			sort.gameSetTargetId,
			index,
			itemsInSort,
			isAd
		)
	end

	self.reportQuickGameLaunch = {
		entry = function()
			return self.props.analytics.reportQuickGameLaunchEntry()
		end,
		success = function()
			return self.props.analytics.reportQuickGameLaunchSuccess()
		end,
		failure = function(reason)
			return self.props.analytics.reportQuickGameLaunchFailed(reason)
		end,
	}
end

function HomeGameGrid:render()
	local sort = self.props.sort
	local gameSortContents = self.props.gameSortContents
	local screenSize = self.props.screenSize
	local layoutOrder = self.props.layoutOrder
	local hasTopPadding = self.props.hasTopPadding
	local numberOfRowsToShow = self.props.numberOfRowsToShow
	local friendFooterEnabled = self.props.friendFooterEnabled

	local sortName = sort and sort.name or ""
	local sortDisplayName = sort and sort.displayName or ""

	local paddingTop = hasTopPadding and GAME_GRID_PADDING or 0
	local paddingLeft = GAME_GRID_PADDING
	local paddingRight = GAME_GRID_PADDING
	local externalPadding = GAME_CAROUSEL_PADDING
	local innerPadding = 0
	local sectionHeader
	if UseNewAppStyle then
		paddingTop = 0
		paddingLeft = 0
		paddingRight = EXTERNAL_PADDING
		externalPadding = EXTERNAL_PADDING
		innerPadding = SECTION_INNER_PADDING

		sectionHeader = Roact.createElement(SectionHeader, {
			text = sortDisplayName,
			layoutOrder = 1,
		})
	else
		sectionHeader = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, TOP_SECTION_HEIGHT),
		}, {
			Title = Roact.createElement(SectionHeader, {
				text = sortDisplayName,
			}),
		})
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		fitFields = {
			Size = FitChildren.FitAxis.Height,
		},
		LayoutOrder = layoutOrder,
	},{
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, innerPadding),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, paddingLeft),
			PaddingRight = UDim.new(0, paddingRight),
			PaddingTop = UDim.new(0, paddingTop),
			PaddingBottom = UDim.new(0, GAME_CAROUSEL_PADDING),
		}),
		SectionHeader = sectionHeader,
		["GameGrid " .. sortName] = Roact.createElement(GameGrid, {
			LayoutOrder = 2,
			entries = gameSortContents and gameSortContents.entries or {},
			reportGameDetailOpened = self.reportGameDetailOpened,
			reportQuickGameLaunch = self.reportQuickGameLaunch,
			numberOfRowsToShow = numberOfRowsToShow,
			windowSize = Vector2.new(screenSize.X - 2 * externalPadding, screenSize.Y),
			friendFooterEnabled = friendFooterEnabled,
		}),
	})
end

HomeGameGrid = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
		}
	end
)(HomeGameGrid)

return RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
})(HomeGameGrid)