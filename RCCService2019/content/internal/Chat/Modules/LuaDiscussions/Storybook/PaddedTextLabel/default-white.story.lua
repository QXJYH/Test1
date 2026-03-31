local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local PaddedTextLabel = require(script.Parent.Parent.Parent.Components.PaddedTextLabel)

return Roact.createElement(PaddedTextLabel, {
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
