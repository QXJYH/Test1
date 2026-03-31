local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)

local Modules = game:GetService("CoreGui").RobloxGui.Modules

local AppPage = require(Modules.LuaApp.AppPage)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local Url = require(Modules.LuaApp.Http.Url)
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)

local NumericalBadge = require(Modules.LuaApp.Components.NumericalBadge)
local EventsNotificationBadge = require(Modules.LuaApp.Components.More.EventsNotificationBadge)

local FFlagMoveMyFeedToMore = FlagSettings.MoveMyFeedToMore()
local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")
local FFlagUseNewAppStyle = FlagSettings.UseNewAppStyle()

local ARROW_RIGHT_IMAGE = FFlagUseNewAppStyle and "LuaApp/icons/arrow_right" or "LuaApp/icons/ic-arrow-right"

local ItemType = {
	-- More Page items
	Catalog = "Catalog",
	BuildersClub = "BuildersClub",
	Profile = "Profile",
	Friends = "Friends",
	Groups = "Groups",
	Inventory = "Inventory",
	Messages = "Messages",
	MyFeed = "MyFeed",
	CreateGames = "CreateGames",
	Events = "Events",
	Blog = "Blog",
	Settings = "Settings",
	About = "About",
	Help = "Help",
	LogOut = "LogOut",

	-- About Page items
	About_AboutUs = "About_AboutUs",
	About_Careers = "About_Careers",
	About_Parents = "About_Parents",
	About_Terms = "About_Terms",
	About_Privacy = "About_Privacy",

	-- Settings Page items
	Settings_AccountInfo = "Settings_AccountInfo",
	Settings_Security = "Settings_Security",
	Settings_Privacy = "Settings_Privacy",
	Settings_Billing = "Settings_Billing",
	Settings_Notifications = "Settings_Notifications",
}

local ItemTextKey = {
	[ItemType.Catalog] = "CommonUI.Features.Label.Catalog",
	[ItemType.BuildersClub] = "CommonUI.Features.Label.BuildersClub",
	[ItemType.Profile] = "CommonUI.Features.Label.Profile",
	[ItemType.Friends] = "CommonUI.Features.Label.Friends",
	[ItemType.Groups] = "CommonUI.Features.Label.Groups",
	[ItemType.Inventory] = "CommonUI.Features.Label.Inventory",
	[ItemType.Messages] = "CommonUI.Features.Label.Messages",
	[ItemType.MyFeed] = "CommonUI.Features.Label.MyFeed",
	[ItemType.CreateGames] = "CommonUI.Features.Label.CreateGames",
	[ItemType.Events] = "CommonUI.Features.Label.Events",
	[ItemType.Blog] = "CommonUI.Features.Label.Blog",
	[ItemType.Settings] = "CommonUI.Features.Label.Settings",
	[ItemType.About] = "CommonUI.Features.Label.About",
	[ItemType.Help] = "CommonUI.Features.Label.Help",
	[ItemType.LogOut] = "Application.Logout.Action.Logout",
	[ItemType.About_AboutUs] = "CommonUI.Features.Label.AboutUs",
	[ItemType.About_Careers] = "CommonUI.Features.Label.Careers",
	[ItemType.About_Parents] = "CommonUI.Features.Label.Parents",
	[ItemType.About_Terms] = "CommonUI.Features.Label.Terms",
	[ItemType.About_Privacy] = "CommonUI.Features.Label.Privacy",
	[ItemType.Settings_AccountInfo] = "Feature.AccountSettings.Heading.Tab.AccountInfo",
	[ItemType.Settings_Security] = "Feature.AccountSettings.Heading.Tab.Security",
	[ItemType.Settings_Privacy] = "Feature.AccountSettings.Heading.Tab.Privacy",
	[ItemType.Settings_Billing] = "Feature.AccountSettings.Heading.Tab.Billing",
	[ItemType.Settings_Notifications] = "Feature.AccountSettings.Heading.Tab.Notifications",
}

local ItemIcon = FFlagUseNewAppStyle and {
	[ItemType.Catalog] = "LuaApp/icons/more_catalog",
	[ItemType.BuildersClub] = "LuaApp/icons/more_buildersclub",
	[ItemType.Profile] = "LuaApp/icons/more_profile",
	[ItemType.Friends] = "LuaApp/icons/more_friends",
	[ItemType.Groups] = "LuaApp/icons/more_groups",
	[ItemType.Inventory] = "LuaApp/icons/more_inventory",
	[ItemType.Messages] = "LuaApp/icons/more_messages",
	[ItemType.MyFeed] = "LuaApp/icons/more_myfeed",
	[ItemType.CreateGames] = "LuaApp/icons/more_creategames",
	[ItemType.Events] = "LuaApp/icons/more_events",
	[ItemType.Blog] = "LuaApp/icons/more_blog",
	[ItemType.Settings] = "LuaApp/icons/more_settings",
	[ItemType.About] = "LuaApp/icons/more_about",
	[ItemType.Help] = "LuaApp/icons/more_help",
} or {
	[ItemType.Catalog] = "LuaApp/icons/ic-more-catalog",
	[ItemType.BuildersClub] = "LuaApp/icons/ic-more-builders-club",
	[ItemType.Profile] = "LuaApp/icons/ic-more-profile",
	[ItemType.Friends] = "LuaApp/icons/ic-more-friends",
	[ItemType.Groups] = "LuaApp/icons/ic-more-groups",
	[ItemType.Inventory] = "LuaApp/icons/ic-more-inventory",
	[ItemType.Messages] = "LuaApp/icons/ic-more-message",
	[ItemType.MyFeed] = "LuaApp/icons/ic-more-my-feed",
	[ItemType.CreateGames] = "LuaApp/icons/ic-more-create",
	[ItemType.Events] = "LuaApp/icons/ic-more-events",
	[ItemType.Blog] = "LuaApp/icons/ic-more-blog",
	[ItemType.Settings] = "LuaApp/icons/ic-more-settings",
	[ItemType.About] = "LuaApp/icons/ic-more-about",
	[ItemType.Help] = "LuaApp/icons/ic-more-help",
}

local ItemUrl
if FFlagLuaAppHttpsWebViews then
	ItemUrl = {
		[ItemType.Catalog] = UrlBuilder.static.catalog(),
		[ItemType.BuildersClub] = UrlBuilder.static.buildersClub(),
		[ItemType.Profile] = UrlBuilder.static.profile(),
		[ItemType.Friends] = UrlBuilder.static.friends(),
		[ItemType.Groups] = UrlBuilder.static.groups(),
		[ItemType.Inventory] = UrlBuilder.static.inventory(),
		[ItemType.Messages] = UrlBuilder.static.messages(),
		[ItemType.MyFeed] = UrlBuilder.static.feed(),
		[ItemType.CreateGames] = UrlBuilder.static.develop(),
		[ItemType.Blog] = UrlBuilder.static.blog(),
		[ItemType.Help] = UrlBuilder.static.help(),
		[ItemType.About_AboutUs] = UrlBuilder.static.about.us(),
		[ItemType.About_Careers] = UrlBuilder.static.about.careers(),
		[ItemType.About_Parents] = UrlBuilder.static.about.parents(),
		[ItemType.About_Terms] = UrlBuilder.static.about.terms(),
		[ItemType.About_Privacy] = UrlBuilder.static.about.privacy(),
		[ItemType.Settings_AccountInfo] = UrlBuilder.static.settings.account(),
		[ItemType.Settings_Security] = UrlBuilder.static.settings.security(),
		[ItemType.Settings_Privacy] = UrlBuilder.static.settings.privacy(),
		[ItemType.Settings_Billing] = UrlBuilder.static.settings.billing(),
		[ItemType.Settings_Notifications] = UrlBuilder.static.settings.notifications(),
	}
else
	ItemUrl = {
		[ItemType.Catalog] = Url.BASE_URL.."catalog",
		[ItemType.BuildersClub] = Url.BASE_URL.."mobile-app-upgrades/native-ios/bc",
		[ItemType.Profile] = Url.BASE_URL.."users/profile",
		[ItemType.Friends] = Url.BASE_URL.."users/friends",
		[ItemType.Groups] = Url.BASE_URL.."my/groups.aspx",
		[ItemType.Inventory] = Url.BASE_URL.."users/inventory",
		[ItemType.Messages] = Url.BASE_URL.."my/messages",
		[ItemType.MyFeed] = Url.BASE_URL.."feeds/inapp",
		[ItemType.CreateGames] = Url.BASE_URL.."develop/landing",
		[ItemType.Blog] = Url.BLOG_URL,
		[ItemType.Help] = Url.BASE_URL.."help",
		[ItemType.About_AboutUs] = Url.CORP_URL,
		[ItemType.About_Careers] = Url.CORP_URL.."careers",
		[ItemType.About_Parents] = Url.CORP_URL.."parents",
		[ItemType.About_Terms] = Url.BASE_URL.."info/terms",
		[ItemType.About_Privacy] = Url.BASE_URL.."info/privacy",
		[ItemType.Settings_AccountInfo] = Url.BASE_URL.."my/account#!/info",
		[ItemType.Settings_Security] = Url.BASE_URL.."my/account#!/security",
		[ItemType.Settings_Privacy] = Url.BASE_URL.."my/account#!/privacy",
		[ItemType.Settings_Billing] = Url.BASE_URL.."my/account#!/billing",
		[ItemType.Settings_Notifications] = Url.BASE_URL.."my/account#!/notifications",
	}
end

local ItemTypesInPage = {
	[AppPage.More] = {
		ItemType.Catalog,
		ItemType.BuildersClub,
		ItemType.Profile,
		ItemType.Friends,
		ItemType.Groups,
		ItemType.Inventory,
		ItemType.Messages,
		ItemType.MyFeed,
		ItemType.CreateGames,
		ItemType.Events,
		ItemType.Blog,
		ItemType.Settings,
		ItemType.About,
		ItemType.Help,
		ItemType.LogOut,
	},
	[AppPage.SimplifiedMore] = {
		ItemType.About_Terms,
		ItemType.LogOut,
	},
	[AppPage.About] = {
		ItemType.About_AboutUs,
		ItemType.About_Careers,
		ItemType.About_Parents,
		ItemType.About_Terms,
		ItemType.About_Privacy,
	},
	[AppPage.Settings] = {
		ItemType.Settings_AccountInfo,
		ItemType.Settings_Security,
		ItemType.Settings_Privacy,
		ItemType.Settings_Billing,
		ItemType.Settings_Notifications,
	},
}

local getWebViewContext = function(contextName)
	if contextName then
		return {
			titleKey = ItemTextKey[contextName],
			url = ItemUrl[contextName],
		}
	end
	return {}
end

local ItemInfo = {
	[ItemType.Catalog] = {
		itemType = ItemType.Catalog,
		textKey = ItemTextKey[ItemType.Catalog],
		icon = ItemIcon[ItemType.Catalog],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Catalog),
	},
	[ItemType.BuildersClub] = {
		itemType = ItemType.BuildersClub,
		textKey = ItemTextKey[ItemType.BuildersClub],
		icon = ItemIcon[ItemType.BuildersClub],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
        context = {
            notificationType = NotificationType.OPEN_BUILDERS_CLUB,
            notificationData = "",
        }
	},
	[ItemType.Profile] = {
		itemType = ItemType.Profile,
		textKey = ItemTextKey[ItemType.Profile],
		icon = ItemIcon[ItemType.Profile],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		urlGenerator = function(userId)
			if FFlagLuaAppHttpsWebViews then
				return userId and UrlBuilder.user.profile({userId = userId}) or nil
			else
				return userId and Url:getUserProfileUrl(userId) or nil
			end
		end,
		context = getWebViewContext(ItemType.Profile),
	},
	[ItemType.Friends] = {
		itemType = ItemType.Friends,
		textKey = ItemTextKey[ItemType.Friends],
		icon = ItemIcon[ItemType.Friends],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeComponent = NumericalBadge,
		badgeCount = 0,
		urlGenerator = function(userId)
			if FFlagLuaAppHttpsWebViews then
				return userId and UrlBuilder.user.friends({userId = userId}) or nil
			else
				return userId and Url:getUserFriendsUrl(userId) or nil
			end
		end,
		context = getWebViewContext(ItemType.Friends),
	},
	[ItemType.Groups] = {
		itemType = ItemType.Groups,
		textKey = ItemTextKey[ItemType.Groups],
		icon = ItemIcon[ItemType.Groups],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Groups),
	},
	[ItemType.Inventory] = {
		itemType = ItemType.Inventory,
		textKey = ItemTextKey[ItemType.Inventory],
		icon = ItemIcon[ItemType.Inventory],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		urlGenerator = function(userId)
			if FFlagLuaAppHttpsWebViews then
				return userId and UrlBuilder.user.inventory({userId = userId}) or nil
			else
				return userId and Url:getUserInventoryUrl(userId) or nil
			end
		end,
		context = getWebViewContext(ItemType.Inventory),
	},
	[ItemType.Messages] = {
		itemType = ItemType.Messages,
		textKey = ItemTextKey[ItemType.Messages],
		icon = ItemIcon[ItemType.Messages],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeComponent = NumericalBadge,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Messages),
	},
	[ItemType.MyFeed] = {
		itemType = ItemType.MyFeed,
		textKey = ItemTextKey[ItemType.MyFeed],
		icon = ItemIcon[ItemType.MyFeed],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.MyFeed),
	},
	[ItemType.CreateGames] = {
		itemType = ItemType.CreateGames,
		textKey = ItemTextKey[ItemType.CreateGames],
		icon = ItemIcon[ItemType.CreateGames],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.CreateGames),
	},
	[ItemType.Events] = {
		itemType = ItemType.Events,
		textKey = ItemTextKey[ItemType.Events],
		icon = ItemIcon[ItemType.Events],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeComponent = EventsNotificationBadge,
		badgeCount = 0,
		context = {
			page = AppPage.Events,
		},
	},
	[ItemType.Blog] = {
		itemType = ItemType.Blog,
		textKey = ItemTextKey[ItemType.Blog],
		icon = ItemIcon[ItemType.Blog],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Blog),
	},
	[ItemType.Settings] = {
		itemType = ItemType.Settings,
		textKey = ItemTextKey[ItemType.Settings],
		icon = ItemIcon[ItemType.Settings],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeComponent = NumericalBadge,
		badgeCount = 0,
		context = {
			page = AppPage.Settings,
		},
	},
	[ItemType.About] = {
		itemType = ItemType.About,
		textKey = ItemTextKey[ItemType.About],
		icon = ItemIcon[ItemType.About],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = {
			page = AppPage.About,
		},
	},
	[ItemType.Help] = {
		itemType = ItemType.Help,
		textKey = ItemTextKey[ItemType.Help],
		icon = ItemIcon[ItemType.Help],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Help),
	},
	[ItemType.LogOut] = {
		itemType = ItemType.LogOut,
		textKey = ItemTextKey[ItemType.LogOut],
		textXAlignment = Enum.TextXAlignment.Center,
		badgeCount = 0,
		context = FFlagEnablePopupDataModelFocusedEvents and {
			page = AppPage.LogoutConfirmation,
		} or {
			notificationType = NotificationType.ACTION_LOG_OUT,
			notificationData = "",
		},
	},
	[ItemType.About_AboutUs] = {
		itemType = ItemType.About_AboutUs,
		textKey = ItemTextKey[ItemType.About_AboutUs],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.About_AboutUs),
	},
	[ItemType.About_Careers] = {
		itemType = ItemType.About_Careers,
		textKey = ItemTextKey[ItemType.About_Careers],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.About_Careers),
	},
	[ItemType.About_Parents] = {
		itemType = ItemType.About_Parents,
		textKey = ItemTextKey[ItemType.About_Parents],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.About_Parents),
	},
	[ItemType.About_Terms] = {
		itemType = ItemType.About_Terms,
		textKey = ItemTextKey[ItemType.About_Terms],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.About_Terms),
	},
	[ItemType.About_Privacy] = {
		itemType = ItemType.About_Privacy,
		textKey = ItemTextKey[ItemType.About_Privacy],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.About_Privacy),
	},
	[ItemType.Settings_AccountInfo] = {
		itemType = ItemType.Settings_AccountInfo,
		textKey = ItemTextKey[ItemType.Settings_AccountInfo],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeComponent = NumericalBadge,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Settings_AccountInfo),
	},
	[ItemType.Settings_Security] = {
		itemType = ItemType.Settings_Security,
		textKey = ItemTextKey[ItemType.Settings_Security],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Settings_Security),
	},
	[ItemType.Settings_Privacy] = {
		itemType = ItemType.Settings_Privacy,
		textKey = ItemTextKey[ItemType.Settings_Privacy],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Settings_Privacy),
	},
	[ItemType.Settings_Billing] = {
		itemType = ItemType.Settings_Billing,
		textKey = ItemTextKey[ItemType.Settings_Billing],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Settings_Billing),
	},
	[ItemType.Settings_Notifications] = {
		itemType = ItemType.Settings_Notifications,
		textKey = ItemTextKey[ItemType.Settings_Notifications],
		rightImage = ARROW_RIGHT_IMAGE,
		badgeCount = 0,
		context = getWebViewContext(ItemType.Settings_Notifications),
	},
}

local ItemInfoTableInPage = {
	[AppPage.More] = {
		{
			ItemInfo[ItemType.Catalog],
			ItemInfo[ItemType.BuildersClub],
		},
		FFlagMoveMyFeedToMore and {
			ItemInfo[ItemType.Profile],
			ItemInfo[ItemType.Friends],
			ItemInfo[ItemType.Groups],
			ItemInfo[ItemType.Inventory],
			ItemInfo[ItemType.Messages],
			ItemInfo[ItemType.MyFeed],
			ItemInfo[ItemType.CreateGames],
		} or {
			ItemInfo[ItemType.Profile],
			ItemInfo[ItemType.Friends],
			ItemInfo[ItemType.Groups],
			ItemInfo[ItemType.Inventory],
			ItemInfo[ItemType.Messages],
			ItemInfo[ItemType.CreateGames],
		},
		{
			ItemInfo[ItemType.Events],
			ItemInfo[ItemType.Blog],
		},
		{
			ItemInfo[ItemType.Settings],
			ItemInfo[ItemType.About],
			ItemInfo[ItemType.Help],
		},
		{
			ItemInfo[ItemType.LogOut],
		},
	},
	[AppPage.SimplifiedMore] = {
		{
			ItemInfo[ItemType.About_Terms],
		},
		{
			ItemInfo[ItemType.LogOut],
		},
	},
	[AppPage.About] = {
		ItemInfo[ItemType.About_AboutUs],
		ItemInfo[ItemType.About_Careers],
		ItemInfo[ItemType.About_Parents],
		ItemInfo[ItemType.About_Terms],
		ItemInfo[ItemType.About_Privacy],
	},
	[AppPage.Settings] = {
		ItemInfo[ItemType.Settings_AccountInfo],
		ItemInfo[ItemType.Settings_Security],
		ItemInfo[ItemType.Settings_Privacy],
		ItemInfo[ItemType.Settings_Billing],
		ItemInfo[ItemType.Settings_Notifications],
	},
}

local MorePageSettings = {}
MorePageSettings.ItemType = ItemType
MorePageSettings.ItemInfo = ItemInfo

function MorePageSettings.GetItemsInPage(page)
	local itemInfoTable = ItemInfoTableInPage[page]

	ArgCheck.isNotNil(itemInfoTable, string.format(
		"%s under More page so that MorePageSettings.GetItemsInPage()", page))

	return itemInfoTable
end

return MorePageSettings
