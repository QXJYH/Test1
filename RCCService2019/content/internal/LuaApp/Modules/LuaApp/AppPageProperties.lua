--[[
	AppPageProperties.lua

	Created by David Brooks on 10/3/2018.

	This module returns a table that contains a set of properties attached to a given page.
	If a page does not have an entry for the property you want to access, you should assume
	a reasonable default.

	Property Name           : Description
	nameLocalizationKey     : Localization key. See AppPageLocalizationKeys.lua (slowly migrating to this file)
	tabBarHidden            : Hide the tab bar automatically when this page is on screen (AppRouter).
	overridesAppRouterTabBarControl : The page has custom tab bar management, so disengage AppRouter control.
	nativeWrapper			: Page is a wrapper that represents a native overlaid UI element.
	renderUnderlyingPage	: The page requires the immediately underlying page to be rendered (e.g. for transparency effect).
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local luaGameDetailsEnabled = FlagSettings.IsLuaGameDetailsPageEnabled()
local IsLuaBottomBarEnabled = FlagSettings.IsLuaBottomBarEnabled()
local FFlagLuaGameDetailsRenderTransparentBackground = settings():GetFFlag("LuaGameDetailsRenderTransparentBackground")
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")
local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")
local FFlagLuaChatShareGameBottomBarOverride = settings():GetFFlag("LuaChatShareGameBottomBarOverride")
local FFlagEnableLuaChatDiscussions = settings():GetFFlag("EnableLuaChatDiscussions")

local gameDetailsAsNativeWrapper = true
if luaGameDetailsEnabled then
	gameDetailsAsNativeWrapper = nil
end

local AppPage = require(game:getService("CoreGui").RobloxGui.Modules.LuaApp.AppPage)

local AppPageProperties = {
	[AppPage.None] = {
		nameLocalizationKey = "CommonUI.Features.Label.Nil"
	},
	[AppPage.Startup] = {
		tabBarHidden = true,
		nameLocalizationKey = "CommonUI.Features.Label.Startup",
	},
	[AppPage.Login] = {
		nameLocalizationKey = "Authentication.Login.Heading.Login",
		tabBarHidden = true,
	},
	[AppPage.UsernameSelectionPage] = {
		nameLocalizationKey = "Authentication.SignUp.Heading.UsernamePage",
		tabBarHidden = true,
	},
	[AppPage.WeChatLoginWrapper] = {
		nativeWrapper = true,
		tabBarHidden = true,
	},
	[AppPage.Home] = {
		nameLocalizationKey = "CommonUI.Features.Label.Home"
	},
	[AppPage.Games] = {
		nameLocalizationKey = "CommonUI.Features.Label.Game"
	},
	[AppPage.Challenge] = {
		nameLocalizationKey = "CommonUI.Features.Label.Challenge",
		tabBarHidden = true,
	},
	[AppPage.GameDetail] = {
		nameLocalizationKey = "CommonUI.Features.Heading.GameDetails",
		nativeWrapper = gameDetailsAsNativeWrapper,
		tabBarHidden = true,
		renderUnderlyingPage = gameDetailsAsNativeWrapper or FFlagLuaGameDetailsRenderTransparentBackground,
		blurUnderlyingPage = FFlagLuaAppEnablePageBlur,
	},
	[AppPage.ChinaBundleModal] = { -- TODO: CLIAVATAR-2349 - clean up or remove China Catalog code
		tabBarHidden = true,
		renderUnderlyingPage = true,
		blurUnderlyingPage = FFlagLuaAppEnablePageBlur,
	},
	[AppPage.AvatarEditor] = {
		nameLocalizationKey = "CommonUI.Features.Label.Avatar"
	},
	[AppPage.Chat] = {
		nameLocalizationKey = "CommonUI.Features.Label.Chat",
		overridesAppRouterTabBarControl = true,
	},
	[AppPage.Discussions] = FFlagEnableLuaChatDiscussions and {
		nameLocalizationKey = "CommonUI.Features.Label.Discussions",
	} or nil,
	[AppPage.ShareGameToChat] = {
		tabBarHidden = true,
	},
	[AppPage.ChinaCatalog] = { -- TODO: CLIAVATAR-2349 - clean up or remove China Catalog code
		nameLocalizationKey = "CommonUI.Features.Label.Catalog"
	},
	[AppPage.More] = {
		nameLocalizationKey = "CommonUI.Features.Label.More"
	},
	[AppPage.About] = {
		nameLocalizationKey = "CommonUI.Features.Label.About"
	},
	[AppPage.Settings] = {
		nameLocalizationKey = "CommonUI.Features.Label.Settings"
	},
	[AppPage.Events] = {
		nameLocalizationKey = "CommonUI.Features.Label.Events"
	},
	[AppPage.GenericWebPage] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.YouTubePlayer] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.PurchaseRobux] = {
		nativeWrapper = true,
		tabBarHidden = FFlagChinaLicensingApp,
		renderUnderlyingPage = true,
	},
	[AppPage.Notifications] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.MyFeed] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.LogoutConfirmation] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.AddFriends] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ViewUserProfile] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ViewProfile] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
    [AppPage.LoginNative] = {
        nativeWrapper = true,
		tabBarHidden = true,
        renderUnderlyingPage = true,
    },
}

if FFlagLuaChatShareGameBottomBarOverride and not IsLuaBottomBarEnabled then
	AppPageProperties[AppPage.ShareGameToChat] = {
		overridesAppRouterTabBarControl  = true,
	}
end

return AppPageProperties