local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppPage = require(Modules.LuaApp.AppPage)
local AppPageProperties = require(Modules.LuaApp.AppPageProperties)

local CLBGameTile = require(Modules.LuaApp.Components.Games.CLBGameTile)
local AppPageWithSmallGrid = require(Modules.LuaApp.Components.Generic.AppPageWithSmallGrid)

local NO_CHALLENGE_TEXT = "Feature.Home.Message.NoChallenges"

local FetchChallengePageData = require(Modules.LuaApp.Thunks.FetchChallengePageData)

local ChallengePage = Roact.PureComponent:extend("ChallengePage")

function ChallengePage:init()
	self.fetchChallengePageData = function()
		local networking = self.props.networking
		local fetchChallengePageData = self.props.fetchChallengePageData

		return fetchChallengePageData(networking)
	end
end

function ChallengePage:didMount()
	self.fetchChallengePageData()
end

function ChallengePage:render()
	local universeIds = self.props.universeIds
	local dataStatus = self.props.dataStatus

	return Roact.createElement(AppPageWithSmallGrid, {
		title = AppPageProperties[AppPage.Challenge].nameLocalizationKey,
		dataStatus = dataStatus,
		onRetry = self.fetchChallengePageData,
		items = universeIds,
		noItemText = NO_CHALLENGE_TEXT,
		getHeight = CLBGameTile.getHeight,
		renderItem = function(item, itemAbsoluteSize, index)
			return Roact.createElement(CLBGameTile, {
				universeId = item,
				LayoutOrder = index,
				width = itemAbsoluteSize.X,
			})
		end,
	})
end

ChallengePage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			universeIds = state.ChallengeItems,
			dataStatus = FetchChallengePageData.GetFetchingStatus(state),
		}
	end,
	function(dispatch)
		return {
			fetchChallengePageData = function(networking)
				return dispatch(FetchChallengePageData.Fetch(networking))
			end,
		}
	end
)(ChallengePage)

return RoactServices.connect({
	networking = RoactNetworking,
})(ChallengePage)
