local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local DiscussionsScreenLayout = require(Components.DiscussionsScreen.DiscussionsScreenLayout)

local DUMMY_ICON = "rbxassetid://2610133241"
local DUMMY_CHANNEL_MODELS = {
	{
		channelId = "1",
		mainText = "hello",
		subText = "general",
	},
	{
		channelId = "2",
		mainText = "howdy",
		subText = "general",
	},
	{
		channelId = "3",
		mainText = "buongiorno",
		subText = "general",
	},
}

local DUMMY_DISCUSSION_MODELS = {
	{
		discussionId = "did1",
		discussionIcon = DUMMY_ICON,
		channelModels = DUMMY_CHANNEL_MODELS,
	},
	{
		discussionId = "did2",
		discussionIcon = DUMMY_ICON,
		channelModels = DUMMY_CHANNEL_MODELS,
	},
	{
		discussionId = "did2",
		discussionIcon = DUMMY_ICON,
		channelModels = DUMMY_CHANNEL_MODELS,
	}
}

return Roact.createElement(DiscussionsScreenLayout, {
	discussionModels = DUMMY_DISCUSSION_MODELS,
})