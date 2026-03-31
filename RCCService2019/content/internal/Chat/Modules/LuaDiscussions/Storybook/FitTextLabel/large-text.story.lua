local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local FitTextLabel = require(Components.FitTextLabel)

local WIDTH = 300

return Roact.createElement("Frame", {
	Size = UDim2.new(0, WIDTH, 1, 0),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
}, {
	FitTextLabel = Roact.createElement(FitTextLabel, {
		maxWidth = WIDTH,
		Text = "The quick brown fox jumps over the lazy dog.",
		TextSize = 45,
	}),
})
