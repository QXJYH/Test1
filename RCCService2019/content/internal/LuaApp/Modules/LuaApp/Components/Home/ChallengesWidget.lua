local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Cryo = require(CorePackages.Cryo)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local memoize = require(Modules.Common.memoize)

local ApiFetchGameIcons = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchGameIcons)
local getCurrentPage = require(Modules.LuaApp.getCurrentPage)

local AppPage = require(Modules.LuaApp.AppPage)
local HomePageIconListWidget = require(Modules.LuaApp.Components.Home.HomePageIconListWidget)

local ChallengesWidget = Roact.PureComponent:extend("ChallengesWidget")

local CHALLENGES_ICON = "LuaApp/icons/challenge_games"
local TITLE_KEY = "CommonUI.Features.Label.Challenge"
local EMPTY_PLACEHOLDER_TEXT_KEY = "Feature.Home.Message.NoChallenges"

function ChallengesWidget:init()
	self.onActivated = function()
		self.props.navigateDown({ name = AppPage.Challenge })
	end

	self.fetchGameIcons = function()
		local networking = self.props.networking
		local games = self.props.games
		local fetchGameIcons = self.props.fetchGameIcons

		fetchGameIcons(networking, games)
	end
end

function ChallengesWidget:didMount()
	self.fetchGameIcons()
end

function ChallengesWidget:render()
	local renderWidth = self.props.renderWidth
	local gameIcons = self.props.iconUrls

	return Roact.createElement(HomePageIconListWidget, {
		titleIcon = CHALLENGES_ICON,
		titleText = TITLE_KEY,
		emptyText = EMPTY_PLACEHOLDER_TEXT_KEY,
		iconUrls = gameIcons,
		renderWidth = renderWidth,
		onActivated = self.onActivated,
	})
end

function ChallengesWidget:didUpdate(prevProps, prevState)
	local isAppOnHomePage = self.props.isAppOnHomePage
	local prevIsAppOnHomePage = prevProps.isAppOnHomePage

	if not prevIsAppOnHomePage and isAppOnHomePage then
		self.fetchGameIcons()
	end
end

local getImageUrls = memoize(function(icons, ids, fetching)
	if fetching then
		return nil
	end
	return Cryo.List.map(ids, function(id)
		local icon = icons[id]
		if icon == nil then
			return ""
		end
		return icon.url or ""
	end)
end)

ChallengesWidget = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameIcons = state.GameIcons
		local universeIds = state.ChallengeItems or {}
		local isAppOnHomePage = getCurrentPage(state) == AppPage.Home
		-- set to true while fetching the id list
		local fetchingUniverseIds = false
		return {
			iconUrls = getImageUrls(gameIcons, universeIds, fetchingUniverseIds),
			games = universeIds,
			isAppOnHomePage = isAppOnHomePage,
		}
	end,
	function(dispatch)
		return {
			fetchGameIcons = function(networking, universeIds)
				return dispatch(ApiFetchGameIcons(networking, universeIds))
			end,
			navigateDown = function(page)
				return dispatch(NavigateDown(page))
			end,
		}
	end
)(ChallengesWidget)

return RoactServices.connect({
	networking = RoactNetworking,
})(ChallengesWidget)
