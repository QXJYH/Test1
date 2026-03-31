local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChatBubbleContainer = require(Components.ChatMessage.ChatBubbleContainer)
local FitTextLabel = require(Components.FitTextLabel)

return Roact.createElement(ChatBubbleContainer, {
}, {
	element1 = Roact.createElement(FitTextLabel, {
		Text = "Hello world!",
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
})
