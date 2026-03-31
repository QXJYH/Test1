local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local FitTextLabel = require(Components.FitTextLabel)

return Roact.createElement(FitTextLabel, {
	maxWidth = 0,
	Text = "This is a longer text message. I hope it is long enough for this example.",
})
