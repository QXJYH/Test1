local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local GamesSearch = require(Modules.LuaApp.Components.Search.GamesSearch)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local ComponentMap = {
	[Constants.SearchTypes.Games] = GamesSearch,
	-- [Constants.SearchTypes.Groups] = GroupsSearch,
	-- [Constants.SearchTypes.Players] = PlayersSearch,
	-- [Constants.SearchTypes.Catalog] = CatalogSearch,
	-- [Constants.SearchTypes.Library] = LibrarySearch,
}

local SearchPage = Roact.PureComponent:extend("SearchPage")

SearchPage.defaultProps = {
	searchType = Constants.SearchTypes.Games,
}

function SearchPage:render()
	local topBarHeight = self.props.topBarHeight
	local searchUuid = self.props.searchUuid
	local searchType = self.props.searchType
	local searchParameters = self.props.searchParameters

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
			},{
				TopBar = Roact.createElement(TopBar, {
					ZIndex = 2,
					showBuyRobux = true,
					showNotifications = true,
					showSearch = true,
				}),
				SearchPage = Roact.createElement("Frame", {
					BackgroundColor3 = style.Theme.BackgroundDefault.Color,
					BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
					Position = UDim2.new(0, 0, 0, topBarHeight),
					Size = UDim2.new(1, 0, 1, -topBarHeight),
				}, {
					Roact.createElement(ComponentMap[searchType], {
						searchUuid = searchUuid,
						searchParameters = searchParameters,
					})
				})
			})
		end)
	else
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
		},{
			TopBar = Roact.createElement(TopBar, {
				ZIndex = 2,
				showBuyRobux = true,
				showNotifications = true,
				showSearch = true,
			}),
			SearchPage = Roact.createElement("Frame", {
				BackgroundColor3 = Constants.Color.GRAY4,
				Position = UDim2.new(0, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, -topBarHeight),
			}, {
				Roact.createElement(ComponentMap[searchType], {
					searchUuid = searchUuid,
					searchParameters = searchParameters,
				})
			})
		})
	end
end

SearchPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			topBarHeight = state.TopBar.topBarHeight,
			searchParameters = state.SearchesParameters[props.searchUuid],
		}
	end
)(SearchPage)

return SearchPage
