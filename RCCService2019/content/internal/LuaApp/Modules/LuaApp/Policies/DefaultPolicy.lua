--[[
  Defines both the default values for policy features, and the list of features
  Feature values in other policy files will be ignored if they are not present here
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local AppPage = require(Modules.LuaApp.AppPage)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local policy = {
    -- Lua Chat
    [AppFeature.ChatConversationHeaderGroupDetails] = true,
    [AppFeature.ChatHeaderSearch] = true,
    [AppFeature.ChatHeaderCreateChatGroup] = true,
    [AppFeature.ChatHeaderHomeButton] = false,
    [AppFeature.ChatHeaderNotifications] = true,
    [AppFeature.ChatPlayTogether] = true,
    [AppFeature.ChatShareGameToChatFromChat] = true,
    [AppFeature.ChatTapConversationThumbnail] = true,

    [AppFeature.GameDetailsMorePage] = true,
    [AppFeature.GameDetailsSubtitle] = true,
    [AppFeature.GameInfoList] = true,
    [AppFeature.GamePlaysAndRatings] = true,
    [AppFeature.Notifications] = true,
    [AppFeature.RecommendedGames] = true,
    [AppFeature.SearchBar] = true,
    [AppFeature.MorePageType] = AppPage.More,
    [AppFeature.SocialLinks] = true,
    [AppFeature.SiteMessageBanner] = true,
    [AppFeature.UseWidthBasedFormFactorRule] = false,
    [AppFeature.UseHomePageWithAvatarAndPanel] = false,
    [AppFeature.UseBottomBar] = true,

    [AppFeature.AvatarHeaderIcon] = "LuaApp/icons/ic-back",
    [AppFeature.AvatarEditorShowBuyRobuxOnTopBar] = true,
    [AppFeature.HomeIcon] = "LuaApp/icons/ic-roblox-close",

    [AppFeature.ShowYouTubeAgeAlert] = function(params)
        if FFlagLuaAppPolicyRoactConnector then
            if params.IsLocalUserUnder13 then
                return true
            end
        else
            if params.userInfo then
                return params.userInfo.under13
            end
        end
        return false
    end,
}

return policy
