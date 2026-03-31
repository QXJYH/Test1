local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local AppPage = require(Modules.LuaApp.AppPage)

-- NOTE values defined here will be ignored if they are not also defined in DefaultPolicy
local policy = {
    -- Lua Chat
    [AppFeature.ChatConversationHeaderGroupDetails] = false,
    [AppFeature.ChatHeaderSearch] = false,
    [AppFeature.ChatHeaderCreateChatGroup] = false,
    [AppFeature.ChatHeaderHomeButton] = true,
    [AppFeature.ChatHeaderNotifications] = false,
    [AppFeature.ChatPlayTogether] = false,
    [AppFeature.ChatShareGameToChatFromChat] = false,
    [AppFeature.ChatTapConversationThumbnail] = false,

    [AppFeature.GameDetailsMorePage] = false,
    [AppFeature.GameDetailsSubtitle] = false,
    [AppFeature.GameInfoList] = false,
    [AppFeature.GamePlaysAndRatings] = false,
    [AppFeature.Notifications] = false,
    [AppFeature.RecommendedGames] = false,
    [AppFeature.SearchBar] = false,
    [AppFeature.MorePageType] = function(params)
        return AppPage.SimplifiedMore
    end,
    [AppFeature.SocialLinks] = false,
    [AppFeature.SiteMessageBanner] = false,
    [AppFeature.UseWidthBasedFormFactorRule] = true,
    [AppFeature.UseHomePageWithAvatarAndPanel] = true,
    [AppFeature.UseBottomBar] = false,
    
    [AppFeature.AvatarHeaderIcon] = "LuaApp/icons/ic-roblox-close",
    [AppFeature.AvatarEditorShowBuyRobuxOnTopBar] = false,
    [AppFeature.HomeIcon] = false,
}

return policy
