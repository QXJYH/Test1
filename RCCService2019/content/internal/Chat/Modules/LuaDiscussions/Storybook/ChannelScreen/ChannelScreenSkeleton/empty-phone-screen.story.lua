local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelScreenSkeleton = require(Components.ChannelScreen.ChannelScreenSkeleton)

local screenSize = Vector3.new(320, 480)

return Roact.createElement("Frame", {
	Size = UDim2.new(0, screenSize.X, 0, screenSize.Y)
}, {
	channelScreen = Roact.createElement(ChannelScreenSkeleton, {

	}),
})
