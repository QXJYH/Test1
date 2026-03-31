local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp
local AppPage = require(LuaApp.AppPage)

return {
	{
		page = AppPage.Home,
		icon = "LuaApp/icons/navbar_home",
		titleKey = "CommonUI.Features.Label.Home",
		badgeCount = 0,
	},
	{
		page = AppPage.Games,
		icon = "LuaApp/icons/navbar_games",
		titleKey = "CommonUI.Features.Label.Game",
		badgeCount = 0,
	},
	{
		page = AppPage.AvatarEditor,
		icon = "LuaApp/icons/navbar_avatar",
		titleKey = "CommonUI.Features.Label.Avatar",
		badgeCount = 0,
	},
	{
		page = AppPage.Chat,
		icon = "LuaApp/icons/navbar_chat",
		titleKey = "CommonUI.Features.Label.Chat",
		badgeCount = 1,
	},
	{
		page = AppPage.More,
		icon = "LuaApp/icons/navbar_more",
		titleKey = "CommonUI.Features.Label.More",
		badgeCount = 0,
	},
}