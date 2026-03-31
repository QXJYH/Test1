local NotificationService = game:GetService("NotificationService")
local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local AppPage = require(Modules.LuaApp.AppPage)

local FFlagPlacesListV1 = require(CorePackages.AppTempCommon.LuaApp.Flags.IsPlacesListV1Enabled)
local GetLuaAppUseNewAvatarThumbnailsApi = require(CorePackages.AppTempCommon.LuaApp.Flags.GetLuaAppUseNewAvatarThumbnailsApi)

game:DefineFastFlag("LuaRemoveRoactRoduxConnectUsage", false)
game:DefineFastFlag("LuaFixRoactRefAssignment", false)

local FlagSettings = {}

local function IsRunningInStudio()
	return game:GetService("RunService"):IsStudio()
end

function FlagSettings.IsLuaGamesPagePreloadingEnabled(platform)
	return not settings():GetFFlag("LuaAppGamesPagePreloadingDisabled")
end

function FlagSettings.IsLuaBottomBarEnabled()
	if IsRunningInStudio() or
		-- Force LuaBottomBar on CLB.
		settings():GetFFlag("ChinaLicensingApp") then
		return true
	else
		return NotificationService.IsLuaBottomBarEnabled
	end
end

function FlagSettings.IsLuaGameDetailsPageEnabled()
	if IsRunningInStudio() or
		NotificationService.IsLuaGameDetailsEnabled or
		settings():GetFFlag("UseDevelopmentLuaGameDetails") or
		-- Force LuaGameDetails on CLB.
		settings():GetFFlag("ChinaLicensingApp") or
		-- AppBridgeRewrite MUST be shipped with 100% LuaGameDetails
		settings():GetFFlag("AppBridgeRewrite")
	then
		return true
	end

	-- BE AWARE: android rollout logic should not be prioritized higher than other flags
	-- Android Rollout
	if UserInputService:GetPlatform() == Enum.Platform.Android then
		if UserInputService:GetDeviceType() == Enum.DeviceType.Phone then
			-- shift number allows different users to get the chances in different feature rollouts
			local rollout = (tonumber(Players.LocalPlayer.UserId) + 50) % 100
			if tonumber(settings():GetFVariable("PercentLuaGameDetailsPageOnAndroidPhone")) > rollout then
				return true
			end
		else
			local rollout = (tonumber(Players.LocalPlayer.UserId) + 75) % 100
			if tonumber(settings():GetFVariable("PercentLuaGameDetailsPageOnAndroidTablet")) > rollout then
				return true
			end
		end
	end

	return false
end

function FlagSettings.IsPeopleListV1Enabled()
	return settings():GetFFlag("LuaHomePeopleListV1V361")
end

function FlagSettings.IsPlacesListV1Enabled()
	return FFlagPlacesListV1()
end

function FlagSettings:IsRemoteThemeCheckEnabled()
	return settings():GetFFlag("LuaEnableRemoteThemeCheckV4") and (not settings():GetFFlag("ChinaLicensingApp"))
end

function FlagSettings:IsLuaAppStopWatchReporterEnabled()
	return settings():GetFFlag("LuaAppEnableStopWatchReporter") and
		not IsRunningInStudio()
end

function FlagSettings:IsLuaGameDetailsPolish367Enabled()
	return FlagSettings.IsLuaGameDetailsPageEnabled() and
		settings():GetFFlag("LuaGameDetailsPolishV367")
end

function FlagSettings.LuaAppLoginEnabled()
	if settings():GetFFlag("AppBridgeStartupController") then
		return true
	end
	if UserInputService:GetPlatform() ~= Enum.Platform.Windows then
		return false
	end
	return settings():GetFFlag("LuaAppLoginEnabled")
end

function FlagSettings.MoveMyFeedToMore()
	-- Lua more page is only depended on FlagSettings.IsLuaBottomBarEnabled()
	return FlagSettings.IsLuaBottomBarEnabled() and settings():GetFFlag("LuaHomeMoveMyFeedToMore")
end

function FlagSettings:IsUseAssetsWithBorderForPresenceEnabled()
	-- Use assets with border for presence on LuaHome page
	return settings():GetFFlag("LuaAppUseGraphicWithBorderForPresenceV373")
end

function FlagSettings.LuaAppUseNewAvatarThumbnailsApi()
	return GetLuaAppUseNewAvatarThumbnailsApi()
end

function FlagSettings.GetDefaultAppPage()
	-- FStringLuaAppDefaultPageOverride overrides the starting/default app page
	-- for the purposes of development and testing. Should not be turned on in production
	local defaultOverride = settings():GetFVariable("LuaAppDefaultPageOverride")
	if #defaultOverride > 0 then
		return defaultOverride
	elseif FlagSettings.LuaAppLoginEnabled() then
		return AppPage.Startup
	else
		return AppPage.Home
	end
end

function FlagSettings.LuaAppPresencePollingIntervalInSeconds()
	return tonumber(settings():GetFVariable("LuaAppPresencePollingIntervalInSecondsV377"))
end

function FlagSettings.UseLuaNavigationLockRefactor()
	return settings():GetFFlag("LuaNavigationLockRefactor388") or settings():GetFFlag("ChinaLicensingApp")
end

function FlagSettings.GetLuaAppRenderTransparentPageMaxCount()
	local fIntLuaAppRenderTransparentPageMaxCount = settings():GetFVariable("LuaAppRenderTransparentPageMaxCount")
	-- This value cannot be smaller than 1.
	return math.max(fIntLuaAppRenderTransparentPageMaxCount, 1)
end

function FlagSettings.EnableLuaAppLoginPageForUniversalAppDev()
	return settings():GetFFlag("EnableLuaAppLoginPageForUniversalAppDev")
end

function FlagSettings.EnableLuaAppParallelLoginDev()
	return settings():GetFFlag("EnableLuaAppParallelLoginDev")
end

function FlagSettings.UseNewAppStyle()
	return not settings():GetFFlag("ChinaLicensingApp") and settings():GetFFlag("LuaAppEnableStyleProvider")
end

function FlagSettings.IsLuaBottomBarWithText()
	return FlagSettings.IsLuaBottomBarEnabled() and NotificationService.IsLuaBottomBarWithText
end

function FlagSettings.UseNewNavBar()
	return FlagSettings.UseNewAppStyle() and settings():GetFFlag("LuaAppUseNewNavBar")
end

function FlagSettings.FixMorePageScroll()
	return settings():GetFFlag("LuaAppFixMorePageScroll")
end

game:DefineFastFlag("LuaAppRefreshScrollingFrameRefactor", false)

function FlagSettings.UseNewRefreshScrollingFrame()
	return FlagSettings.IsLuaBottomBarEnabled() and
		FlagSettings.UseNewAppStyle() and game:GetFastFlag("LuaAppRefreshScrollingFrameRefactor")
end

return FlagSettings
