local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact

local ChannelScreenContainer = require(LuaDiscussions.Components.ChannelScreen.ChannelScreenContainer)

local DiscussionsEntrypoint = Roact.PureComponent:extend("DiscussionsEntrypoint")
DiscussionsEntrypoint.defaultProps = {}

function DiscussionsEntrypoint:render()
	return Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		channelScreen = Roact.createElement(ChannelScreenContainer, {
			channelId = "demo-1",
		}),
	})
end

return DiscussionsEntrypoint
