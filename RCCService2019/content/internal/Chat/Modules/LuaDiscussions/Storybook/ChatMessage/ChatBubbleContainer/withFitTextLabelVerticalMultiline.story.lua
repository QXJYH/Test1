local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChatBubbleContainer = require(Components.ChatMessage.ChatBubbleContainer)
local FitTextLabel = require(Components.FitTextLabel)

return Roact.createElement(ChatBubbleContainer, {
}, {
	element1 = Roact.createElement(FitTextLabel, {
		maxWidth = 350,
		Text = "Lorem ipsum dolor amet vHS tilde vape authentic williamsburg poke artisan selvage mollit ullamco in fashion axe literally. Shaman gastropub tousled blue bottle, retro godard tote bag. Typewriter pariatur salvia, aliquip consequat plaid viral. Ipsum gochujang selfies, retro snackwave PBR&B cloud bread whatever authentic hexagon next level.",
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
})
