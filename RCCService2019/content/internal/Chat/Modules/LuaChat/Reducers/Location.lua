local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common
local LuaChat = Modules.LuaChat

local PopRoute = require(LuaChat.Actions.PopRoute)
local RemoveRoute = require(LuaChat.Actions.RemoveRoute)
local SetRoute = require(LuaChat.Actions.SetRoute)
local FetchChatSettingsCompleted = require(LuaChat.Actions.FetchChatSettingsCompleted)

local DialogInfo = require(LuaChat.DialogInfo)
local Immutable = require(Common.Immutable)

local FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults =
	settings():GetFFlag("LuaChatScreenManagerAlwaysUpdatesWithDefaultsV390")
local FFlagLuaChatContactSettingsOffConversationFix =
	settings():GetFFlag("LuaChatContactSettingsOffConversationFix")

local DEFAULT_STATE = {
	current = {},
	history = {}
}

local conversationHubIntent = {
	intent = DialogInfo.Intent.ConversationHub,
	parameters = {},
}
local STATE_WITH_CONVERSATIONHUB_ONLY = {
	current = conversationHubIntent,
	history = {conversationHubIntent},
}
if FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults then
	DEFAULT_STATE = STATE_WITH_CONVERSATIONHUB_ONLY
end

return function(state, action)
	state = state or DEFAULT_STATE

	if action.type == SetRoute.name then
		local current = state.current
		local history = state.history

		local routeData = {
			intent = action.intent,
			popToIntent = action.popToIntent,
			parameters = action.parameters
		}

		if action.popToIntent then
			local found = false
			for i = #history, 1, -1 do
				local loc = history[i]
				if loc.intent == action.popToIntent then
					history = Immutable.RemoveRangeFromList(history, i + 1, #history - i)
					current = history[#history]
					found = true
					break
				end
			end

			if not found then
				warn("Could not pop to unavailable intent: " .. action.popToIntent)
			end
		end

		if routeData.intent ~= nil then
			current = routeData
			history = Immutable.Append(history, routeData)
		end

		return {
			current = current,
			history = history
		}

	elseif action.type == PopRoute.name then
		local current
		local history = state.history

		if #history <= 1 then
			return state
		end

		history = Immutable.RemoveFromList(history, #history)
		current = history[#history]
		if not current then
			current = {}
		end

		return {
			current = current,
			history = history
		}

	elseif action.type == RemoveRoute.name then
		local intent = action.intent
		local history = state.history

		for i = #history, 1, -1 do
			local loc = history[i]
			if loc.intent == intent then
				history = Immutable.RemoveFromList(history, i)
				break
			end
		end

		local current = history[#history] or {}

		return {
			current = current,
			history = history
		}

	elseif FFlagLuaChatContactSettingsOffConversationFix and action.type == FetchChatSettingsCompleted.name then
		if (not action.settings.chatEnabled) then
			return STATE_WITH_CONVERSATIONHUB_ONLY
		end
	end

	return state
end