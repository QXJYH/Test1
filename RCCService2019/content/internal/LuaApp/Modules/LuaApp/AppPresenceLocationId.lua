local AppPage = require(script.Parent.AppPage)

local FFlagEnableLuaChatDiscussions = settings():GetFFlag("EnableLuaChatDiscussions")

local AppPresenceLocationId = {}

local locationIdMap = {
	[AppPage.None] = "None",
	[AppPage.Startup] = "Startup",
	[AppPage.Login] = "Login",
	[AppPage.WeChatLoginWrapper] = "WeChatLogin",
	[AppPage.Home] = "Home",
	[AppPage.Games] = "Games",
	[AppPage.ChinaCatalog] = "ChinaCatalog",
	[AppPage.Challenge] = "Challenge",
	[AppPage.GamesList] = "Games_List",
	[AppPage.GameDetail] = "Games_Detail",
	[AppPage.ChinaBundleModal] = "ChinaBundleModal",
	[AppPage.SearchPage] = "Search",
	[AppPage.AvatarEditor] = "Avatar",
	[AppPage.Chat] = "Chat",
	[AppPage.Discussions] = FFlagEnableLuaChatDiscussions and "Discussions" or nil,
	[AppPage.ShareGameToChat] = "ShareGameToChat",
	[AppPage.More] = "More",
	[AppPage.SimplifiedMore] = "SimplifiedMore",
	[AppPage.About] = "About",
	[AppPage.Settings] = "Settings",
	[AppPage.Events] = "Events",
	[AppPage.GenericWebPage] = "GenericWebPage",
	[AppPage.YouTubePlayer] = "YouTubePlayer",
	[AppPage.PurchaseRobux] = "PurchaseRobux",
	[AppPage.Notifications] = "Notifications",
	[AppPage.AgreementPage] = "Agreement",
	[AppPage.MyFeed] = "MyFeed",
	[AppPage.LogoutConfirmation] = "Logout",
    [AppPage.LoginNative] = "LoginNative",
}

setmetatable(AppPresenceLocationId, {
	__newindex = function(t, key, value)
		error("locationId is read-only.")
	end,
	__index = function(t, key)
		return locationIdMap[key]
	end
})

return AppPresenceLocationId