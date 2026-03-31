local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local PlainText = require(Components.ChatMessage.PlainText)

return Roact.createElement(PlainText, {
	messageChunk = {
		message = "Hey.",
	},
	innerPadding = 12,
})
