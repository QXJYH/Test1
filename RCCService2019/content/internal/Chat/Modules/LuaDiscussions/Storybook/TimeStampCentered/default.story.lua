local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local TimeStampCentered = require(Components.ChatMessage.TimeStampCentered)

return Roact.createElement(TimeStampCentered, {
	isoTime = "1994-12-12",
})
