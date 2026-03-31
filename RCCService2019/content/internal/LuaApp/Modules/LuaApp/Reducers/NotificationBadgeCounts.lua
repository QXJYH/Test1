local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Rodux = require(Modules.Common.Rodux)
local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Cryo)

local SetNotificationCount = require(Modules.LuaApp.Actions.SetNotificationCount)
local SetFriendRequestsCount = require(Modules.LuaApp.Actions.SetFriendRequestsCount)
local SetUnreadMessageCount = require(Modules.LuaApp.Actions.SetUnreadMessageCount)
local SetEmailNotificationCount = require(Modules.LuaApp.Actions.SetEmailNotificationCount)
local SetPasswordNotificationCount = require(Modules.LuaApp.Actions.SetPasswordNotificationCount)

local FFlagFixCountOfUnreadNotificationError = settings():GetFFlag("FixCountOfUnreadNotificationError")

if FFlagFixCountOfUnreadNotificationError then
	return Rodux.createReducer({
		TopBarNotificationIcon = 0,
		MorePageMessages = 0,
		MorePageFriends = 0,
		MorePageEmailSettings = 0,
		MorePagePasswordSettings = 0,
		MorePageSettings = 0,
	}, {
		[SetNotificationCount.name] = function(state, action)
			return Cryo.Dictionary.join(state, {
				TopBarNotificationIcon = action.notificationCount
			})
		end,
		[SetFriendRequestsCount.name] = function(state, action)
			return Cryo.Dictionary.join(state, {
				MorePageFriends = action.count,
			})
		end,
		[SetUnreadMessageCount.name] = function(state, action)
			return Cryo.Dictionary.join(state, {
				MorePageMessages = action.count,
			})
		end,
		[SetEmailNotificationCount.name] = function(state, action)
			return Cryo.Dictionary.join(state, {
				MorePageEmailSettings = action.count,
				MorePageSettings = action.count + state.MorePagePasswordSettings,
			})
		end,
		[SetPasswordNotificationCount.name] = function(state, action)
			return Cryo.Dictionary.join(state, {
				MorePagePasswordSettings = action.count,
				MorePageSettings = action.count + state.MorePageEmailSettings,
			})
		end,
	})
else
	return function(state, action)
		state = state or {
			TopBarNotificationIcon = 0,
			MorePageMessages = 0,
			MorePageFriends = 0,
			MorePageEmailSettings = 0,
			MorePagePasswordSettings = 0,
			MorePageSettings = 0,
		}

		if action.type == SetNotificationCount.name then
			state.TopBarNotificationIcon = action.notificationCount
		elseif action.type == SetFriendRequestsCount.name then
			return Cryo.Dictionary.join(state, {
				MorePageFriends = action.count,
			})
		elseif action.type == SetUnreadMessageCount.name then
			return Cryo.Dictionary.join(state, {
				MorePageMessages = action.count,
			})
		elseif action.type == SetEmailNotificationCount.name then
			return Cryo.Dictionary.join(state, {
				MorePageEmailSettings = action.count,
				MorePageSettings = action.count + state.MorePagePasswordSettings,
			})
		elseif action.type == SetPasswordNotificationCount.name then
			return Cryo.Dictionary.join(state, {
				MorePagePasswordSettings = action.count,
				MorePageSettings = action.count + state.MorePageEmailSettings,
			})
		end

		return state
	end
end