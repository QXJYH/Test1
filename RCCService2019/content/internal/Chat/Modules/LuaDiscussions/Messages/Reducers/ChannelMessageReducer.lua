local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Rodux = dependencies.Rodux

local reducers = script.Parent.ChannelMessage
local byId = require(reducers.byId)
local byChannelId = require(reducers.byChannelId)

return Rodux.combineReducers({
	byChannelId = byChannelId,
	byId = byId,
})