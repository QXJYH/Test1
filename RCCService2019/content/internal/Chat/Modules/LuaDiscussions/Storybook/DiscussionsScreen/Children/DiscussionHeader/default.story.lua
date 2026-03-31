local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local DiscussionHeader = require(Components.DiscussionsScreen.Children.DiscussionsHeader)

return Roact.createElement(DiscussionHeader, {
	channelIds = {"id1", "id2", "id3"},
	discussionIcon = "rbxassetid://2610133241",
	discussionBackground = "rbxassetid://2610133241",
})