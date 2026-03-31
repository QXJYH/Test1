local NotificationService = game:GetService("NotificationService")
local CorePackages = game:GetService("CorePackages")
local Players = game:GetService("Players")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Constants = require(Modules.LuaApp.Constants)
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local PolicyReader = require(Modules.LuaApp.Policies.PolicyReader)
local NetworkProfiler = require(CorePackages.AppTempCommon.LuaApp.NetworkProfiler)

local ApiFetchUsersThumbnail = require(Modules.LuaApp.Thunks.ApiFetchUsersThumbnail)
local FetchNotificationCount = require(Modules.LuaApp.Thunks.FetchNotificationCount)
local ApiFetchUnreadNotificationCount = require(Modules.LuaApp.Thunks.ApiFetchUnreadNotificationCount)
local ApiFetchSiteMessage = require(Modules.LuaApp.Thunks.ApiFetchSiteMessage)
local ReportToDiagByCountryCode = require(Modules.LuaApp.Http.Requests.ReportToDiagByCountryCode)

local FetchHomePageData = require(Modules.LuaApp.Thunks.FetchHomePageData)
local FetchGamesPageData = require(Modules.LuaApp.Thunks.FetchGamesPageData)
local FetchChatData = require(Modules.LuaApp.Thunks.FetchChatData)
local FetchPremiumMigrationNotice = require(Modules.LuaApp.Thunks.FetchPremiumMigrationNotice)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseLuaBottomBar = FlagSettings.IsLuaBottomBarEnabled()
local FFlagLuaAppPreloadChatRefactor = settings():GetFFlag("LuaAppPreloadChatRefactor")
local siteMessageBannerEnabled = settings():GetFFlag("LuaAppSiteMessageBannerEnabled")
local FFlagLuaAppUseNewAvatarThumbnailsApi = FlagSettings.LuaAppUseNewAvatarThumbnailsApi()
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")
local FFlagLuaAppPremiumUpdatePrompt = settings():GetFFlag("LuaAppPremiumUpdatePrompt")
local FFlagLuaChatFetchChatSettings = settings():GetFFlag("LuaChatFetchChatSettings")

local StopWatchReporter = FlagSettings:IsLuaAppStopWatchReporterEnabled() and game:GetService("StopWatchReporter")

local function preloadChatData(store)
	local promises = {}

	if NotificationService.IsLuaChatEnabled then
		if FFlagLuaChatFetchChatSettings then
			table.insert(promises, store:dispatch(FetchChatData(nil, true)))
		else
			store:dispatch(FetchChatData(nil, true))
		end
	end

	return promises
end

local function startStandardAppFirstClassPagePreloadOperations(preloadingContext)
	local networkImpl = preloadingContext.networkImpl
	local analytics = preloadingContext.analytics
	local store = preloadingContext.store
	local userId = preloadingContext.userId

	local promises = {}

	-- Preload home page data
	if store:getState().Startup.HomePageDataStatus == RetrievalStatus.NotStarted then

		local fetchTimeCheckPoints = nil
		if StopWatchReporter then
			fetchTimeCheckPoints = {
				taskIdFriends = -1,
				taskIdPresences = -1,
				taskIdSortTokens = -1,
				startFetchUserFriends = function(self)
					self.taskIdFriends = StopWatchReporter:StartTask("Startup", "FetchUsersFriends") end,
				finishFetchUserFriends = function(self)
					StopWatchReporter:FinishTask(self.taskIdFriends) end,
				startFetchUsersPresences = function(self)
					self.taskIdPresences = StopWatchReporter:StartTask("Startup", "FetchUsersPresences") end,
				finishFetchUsersPresences = function(self)
					StopWatchReporter:FinishTask(self.taskIdPresences) end,
				startFetchSortTokens = function(self)
					self.taskIdSortTokens = StopWatchReporter:StartTask("Startup", "FetchSortTokens") end,
				finishFetchSortTokens = function(self)
					StopWatchReporter:FinishTask(self.taskIdSortTokens) end
			}
		end

		local homePagePromise = store:dispatch(
			FetchHomePageData(networkImpl, analytics, userId, fetchTimeCheckPoints))

		table.insert(promises, homePagePromise)
	end

	return PromiseUtilities.Batch(promises):andThen(function(results)
		local failureCount = PromiseUtilities.CountResults(results).failureCount

		if failureCount ~= 0 then
			warn(string.format("%d of %d first-class preloading operations failed!", failureCount, #promises))
		end
		if StopWatchReporter then
			StopWatchReporter:SendReport("Startup")
		end
	end)
end

local function startStandardAppSecondClassPagePreloadOperations(preloadingContext)
	local networkImpl = preloadingContext.networkImpl
	local analytics = preloadingContext.analytics
	local store = preloadingContext.store
	local policyData = preloadingContext.policyData
	local platform = preloadingContext.platform
	local userId = preloadingContext.userId

	local promises = {}

	-- Preload user thumbnail
	if FFlagLuaAppUseNewAvatarThumbnailsApi then
		table.insert(promises, store:dispatch(ApiFetchUsersThumbnail.Fetch(
			networkImpl, {userId}, Constants.AvatarThumbnailRequests.HOME_HEADER_USER
		)))
	else
		table.insert(promises, store:dispatch(ApiFetchUsersThumbnail(
			networkImpl, {userId}, Constants.AvatarThumbnailRequests.HOME_HEADER_USER
		)))
	end

	if UseLuaBottomBar then
		-- Preload notification data
		table.insert(promises, store:dispatch(FetchNotificationCount(networkImpl)))
	else
		-- Preload notification data
		table.insert(promises, store:dispatch(ApiFetchUnreadNotificationCount(networkImpl)))
	end

	-- Preload games page data
	if FlagSettings.IsLuaGamesPagePreloadingEnabled(platform) and
		store:getState().Startup.GamesPageDataStatus == RetrievalStatus.NotStarted then

		local gamesDataPromise = store:dispatch(
			FetchGamesPageData(networkImpl, analytics))
		table.insert(promises, gamesDataPromise)
	end

	-- Preload chat data
	if FFlagLuaAppPreloadChatRefactor then
		promises = Cryo.Dictionary.join(promises, preloadChatData(store))
	else
		if NotificationService.IsLuaChatEnabled then
			if FFlagLuaChatFetchChatSettings then
				table.insert(promises, store:dispatch(FetchChatData(nil, true)))
			else
				store:dispatch(FetchChatData(nil, true))
			end
		end
	end

	-- Fetch site message banner
	local showSiteMessageBanner
	if FFlagLuaAppPolicyRoactConnector then
		showSiteMessageBanner = policyData.getSiteMessageBanner()
	else
		showSiteMessageBanner = PolicyReader.IsFeatureEnabled(policyData, AppFeature.SiteMessageBanner)
	end
	if siteMessageBannerEnabled and showSiteMessageBanner then
		table.insert(promises, store:dispatch(ApiFetchSiteMessage(networkImpl)))
	end

	-- Premium migration notice
	if FFlagLuaAppPremiumUpdatePrompt then
		table.insert(promises, store:dispatch(FetchPremiumMigrationNotice(networkImpl)))
	end

	return PromiseUtilities.Batch(promises):andThen(function(results)
		local failureCount = PromiseUtilities.CountResults(results).failureCount

		if failureCount ~= 0 then
			warn(string.format("%d of %d second-class preloading operations failed!", failureCount, #promises))
		end
	end)
end

local function startCLBFirstClassPagePreloadOperations(preloadingContext)
	local store = preloadingContext.store

	local promises = preloadChatData(store)

	return PromiseUtilities.Batch(promises)
end

return function(networkImpl, analytics, policyData)
	return function(store)
		local preloadingContext = {
			networkImpl = networkImpl,
			analytics = analytics,
			store = store,
			policyData = policyData,
			platform = store:getState().Platform,
			userId = tostring(Players.LocalPlayer.UserId),
		}

		if FFlagChinaLicensingApp then
			return startCLBFirstClassPagePreloadOperations(preloadingContext)
		else
			return startStandardAppFirstClassPagePreloadOperations(preloadingContext):andThen(function()
				NetworkProfiler:report(ReportToDiagByCountryCode)
				return startStandardAppSecondClassPagePreloadOperations(preloadingContext)
			end)
		end
	end
end
