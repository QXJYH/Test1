local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local GradientImage = require(Components.ChatHeader.GradientImage)

return Roact.createElement("Frame", {
	Size = UDim2.new(0, 300, 0, 64),
}, {
	background = Roact.createElement(GradientImage),
})
