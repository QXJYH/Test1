local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChatBubbleContainer = require(Components.ChatMessage.ChatBubbleContainer)

return Roact.createElement(ChatBubbleContainer, {
	width = UDim.new(0, 50),
}, {
	element1 = Roact.createElement("TextLabel", {
		Text = "50x50",
		BackgroundColor3 = Color3.fromRGB(150, 0, 150),
		Size = UDim2.new(0, 50, 0, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
})
