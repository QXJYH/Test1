local Modules = game:GetService("CoreGui").RobloxGui.Modules

-- main AppShell reducer
local Reducers = script.Parent
local RobloxUser = require(Reducers.RobloxUser)
local ScreenList = require(Reducers.ScreenList)
local XboxUser = require(Reducers.XboxUser)
local UserThumbnails = require(Reducers.UserThumbnails)
local Friends = require(Reducers.Friends)
local RenderedFriends = require(Reducers.RenderedFriends)
local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
local ResetStore = require(Modules.Shell.Actions.ResetStore)

return function(state, action)
	state = state or {}

	if action.type == ResetStore.name then
		state = {}
	end

	return {
		-- Use reducer composition to add reducers here
		RobloxUser = RobloxUser(state.RobloxUser, action),
		ScreenList = ScreenList(state.ScreenList, action),
		XboxUser = XboxUser(state.XboxUser, action),
		UserThumbnails = UserThumbnails(state.UserThumbnails, action),
		Friends = Friends(state.Friends, action),
		RenderedFriends = RenderedFriends(state.RenderedFriends, action),
		AEAppReducer = AEAppReducer(state.AEAppReducer, action),
	}
end
