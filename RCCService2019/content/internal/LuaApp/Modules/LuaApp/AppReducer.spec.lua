return function()
	local FFlagEnableLuaChatDiscussions = settings():GetFFlag("EnableLuaChatDiscussions")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppReducer = require(Modules.LuaApp.AppReducer)

	it("has the expected fields, and only the expected fields", function()
		local state = AppReducer(nil, {})

		local expectedKeys = {
			ChatAppReducer = true,
			ConnectionState = true,
			CurrentToastMessage = true,
			CentralOverlay = true,
			DeviceOrientation = true,
			FormFactor = true,
			ScreenGuiBlur = true,
			FriendCount = true,
			Games = true,
			GameSortGroups = true,
			GameSorts = true,
			GameSortsContents = true,
			GameIcons = true,
			GameThumbnails = true,
			GameDetails = true,
			GameSocialLinks = true,
			GameFollowings = true,
			GamePasses = true,
			GameBadges = true,
			UserRobux = true,
			GameDetailsPageDataStatus = true,
			GameVotes = true,
			GameFavorites = true,
			GamesProductInfo = true,
			GameMedia = true,
			GlobalGuiInset = true,
			InGameUsersByGame = true,
			LocalUserId = true,
			Navigation = true,
			NextDataExpirationTime = true,
			NextTokenRefreshTime = true,
			NotificationBadgeCounts = true,
			Platform = true,
			PlayabilityStatus = true,
			RecommendedGameEntries = true,
			RequestsStatus = true,
			ScreenSize = true,
			SignUpInfo = true,
			Search = true,
			SearchesParameters = true,
			SponsoredEvents = true,
			Startup = true,
			TabBarVisible = true,
			TopBar = true,
			SiteMessage = true,
			Users = true,
			UsersAsync = true,
			UserGameVotes = true,
			UserStatuses = true,
			AEAppReducer = true,
			UniversePlaceInfos = true,
			FetchingStatus = true,
			ChallengeItems = true,
			CatalogAppReducer = true,
			Authentication = true,
			IsLocalUserUnder13 = true,
		}

		if FFlagEnableLuaChatDiscussions then
			expectedKeys.DiscussionsAppReducer = true
		end

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end
