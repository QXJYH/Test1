local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local PaddedTextLabel = require(script.Parent.Parent.Parent.Components.PaddedTextLabel)

return Roact.createElement(PaddedTextLabel, {
	PaddingBottom = 32,
	PaddingLeft = 32,
	PaddingRight = 32,
	PaddingTop = 32,
})
