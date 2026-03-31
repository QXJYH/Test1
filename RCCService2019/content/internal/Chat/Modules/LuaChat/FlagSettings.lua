local Modules = game:GetService("CoreGui").RobloxGui.Modules

local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local AppFlagSettings = require(Modules.LuaApp.FlagSettings)

local isFeatureEnabled = require(Modules.LuaChat.Utils.isFeatureEnabled)

local FFlagLuaChatNavigateToLuaGameDetails = settings():GetFFlag("LuaChatNavigateToLuaGameDetailsV2")

local FlagSettings = {}

function FlagSettings.IsLuaChatPlayTogetherEnabled(appState)
	return isFeatureEnabled(appState, AppFeature.ChatPlayTogether)
end

function FlagSettings.isMessageTypeEnabled()
	return true
end

function FlagSettings.isLuaGameDetailsEnabled()
	return AppFlagSettings.IsLuaBottomBarEnabled() and FFlagLuaChatNavigateToLuaGameDetails
end

function FlagSettings.EnableLuaChatDiscussions()
	return settings():GetFFlag("EnableLuaChatDiscussions") and settings():GetFFlag("LuaAppEnableStyleProvider")
end

return FlagSettings