local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Rodux = require(game:GetService("CorePackages").Rodux)

local FFlagEnableLuaChatDiscussions = settings():GetFFlag("EnableLuaChatDiscussions")
local DiscussionsAppReducer = nil
if FFlagEnableLuaChatDiscussions then
	DiscussionsAppReducer = require(Modules.LuaDiscussions.DiscussionsAppReducer)
end

local CatalogAppReducer = function() return {} end
if (settings():GetFFlag("ChinaLicensingApp")) then
	CatalogAppReducer = require(Modules.LuaApp.Reducers.Catalog.CatalogAppReducer)
end
local ClearUserSpecificData = require(Modules.LuaApp.Actions.ClearUserSpecificData)
local FlagSettings = require(Modules.LuaApp.FlagSettings)


local function globalActionReducer(state, action)
	-- ClearUserSpecificData will tear down the state of all
	-- reducers except for those whitelisted here.
	if FlagSettings.LuaAppLoginEnabled() then
		if action.type == ClearUserSpecificData.name then
			local oldState = state
			state = {
				ScreenSize = state.ScreenSize,
				DeviceOrientation = state.DeviceOrientation,
				FormFactor = state.FormFactor,
			}
			if FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
				state.GlobalGuiInset = oldState.GlobalGuiInset
				state.TopBar = oldState.TopBar
				state.Authentication = oldState.Authentication
			end
		end
	end

	return state
end

local combineReducers = Rodux.combineReducers({
	DeviceOrientation = require(Modules.LuaApp.Reducers.DeviceOrientation),
	TopBar = require(Modules.LuaApp.Reducers.TopBar),
	SiteMessage = require(Modules.LuaApp.Reducers.SiteMessage),
	TabBarVisible = require(Modules.LuaApp.Reducers.TabBarVisible),
	FetchingStatus = require(Modules.LuaApp.Reducers.FetchingStatus),

	-- Users
	Users = require(Modules.LuaApp.Reducers.Users),
	UsersAsync = require(Modules.LuaChat.Reducers.UsersAsync),
	UserStatuses = require(Modules.LuaApp.Reducers.UserStatuses),
	LocalUserId = require(Modules.LuaApp.Reducers.LocalUserId),
	InGameUsersByGame = require(Modules.LuaApp.Reducers.InGameUsersByGame),

	--SignUp
	SignUpInfo = require(Modules.LuaApp.Reducers.SignUpInfo),

	-- Game Data
	Games = require(Modules.LuaApp.Reducers.Games),
	GameSorts = require(Modules.LuaApp.Reducers.GameSorts),
	GameSortGroups = require(Modules.LuaApp.Reducers.GameSortGroups),
	GameIcons = require(Modules.LuaApp.Reducers.GameIcons),
	GameThumbnails = require(Modules.LuaApp.Reducers.GameThumbnails),
	GameDetails = require(Modules.LuaApp.Reducers.GameDetails),
	GameSocialLinks = require(Modules.LuaApp.Reducers.GameSocialLinks),
	GameFollowings = require(Modules.LuaApp.Reducers.GameFollowings),
	GamePasses = require(Modules.LuaApp.Reducers.GamePasses),
	GameBadges = require(Modules.LuaApp.Reducers.GameBadges),
	UserRobux = require(Modules.LuaApp.Reducers.UserRobux),
	GameDetailsPageDataStatus = require(Modules.LuaApp.Reducers.GameDetailsPageDataStatus),
	GameVotes = require(Modules.LuaApp.Reducers.GameVotes),
	UserGameVotes = require(Modules.LuaApp.Reducers.UserGameVotes),
	GameFavorites = require(Modules.LuaApp.Reducers.GameFavorites),
	GamesProductInfo = require(Modules.LuaApp.Reducers.GamesProductInfo),
	NextDataExpirationTime = require(Modules.LuaApp.Reducers.NextDataExpirationTime),
	NextTokenRefreshTime = require(Modules.LuaApp.Reducers.NextTokenRefreshTime),
	GameSortsContents = require(Modules.LuaApp.Reducers.GameSortsContents),
	RecommendedGameEntries = require(Modules.LuaApp.Reducers.RecommendedGameEntries),
	GameMedia = require(Modules.LuaApp.Reducers.GamesReducers.GameMedia),

	PlayabilityStatus = require(Modules.LuaApp.Reducers.PlayabilityStatus),
	UniversePlaceInfos = require(Modules.LuaApp.Reducers.UniversePlaceInfos),

	CurrentToastMessage = require(Modules.LuaApp.Reducers.CurrentToastMessage),
	CentralOverlay = require(Modules.LuaApp.Reducers.CentralOverlay),

	RequestsStatus = require(Modules.LuaApp.Reducers.RequestsStatus),

	Navigation = require(Modules.LuaApp.Reducers.Navigation),

	Search = require(Modules.LuaApp.Reducers.Search),
	SearchesParameters = require(Modules.LuaApp.Reducers.SearchesParameters),

	FriendCount = require(Modules.LuaChat.Reducers.FriendCount),
	ConnectionState = require(Modules.LuaChat.Reducers.ConnectionState),

	GlobalGuiInset = require(Modules.LuaApp.Reducers.GlobalGuiInset),
	ScreenSize = require(Modules.LuaApp.Reducers.ScreenSize),
	FormFactor = require(Modules.LuaApp.Reducers.FormFactor),
	ScreenGuiBlur = require(Modules.LuaApp.Reducers.ScreenGuiBlur),
	Platform = require(Modules.LuaApp.Reducers.Platform),
	SponsoredEvents = require(Modules.LuaApp.Reducers.SponsoredEvents),

	ChatAppReducer = require(Modules.LuaChat.AppReducer),
	DiscussionsAppReducer = FFlagEnableLuaChatDiscussions and DiscussionsAppReducer or nil,
	AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer),

	Startup = require(Modules.LuaApp.Reducers.Startup),
	NotificationBadgeCounts = require(Modules.LuaApp.Reducers.NotificationBadgeCounts),

	-- CLB
	ChallengeItems = require(Modules.LuaApp.Reducers.ChallengeItems),
	CatalogAppReducer = CatalogAppReducer,
	Authentication = require(Modules.LuaApp.Reducers.Authentication),
	IsLocalUserUnder13 = require(Modules.LuaApp.Reducers.IsLocalUserUnder13),
})

return function(state, action)
	return combineReducers(globalActionReducer(state, action), action)
end