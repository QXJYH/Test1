local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Rodux = dependencies.Rodux

local ChannelMessageReducer = require(LuaDiscussions.Messages.Reducers.ChannelMessageReducer)

return Rodux.combineReducers({
	channelMessages = ChannelMessageReducer,
})