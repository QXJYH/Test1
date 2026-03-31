local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local ChannelListItem = require(Components.DiscussionsScreen.Children.ChannelListItem)

return Roact.createElement(ChannelListItem, {
        mainText = "Africa",
        subText = "[Toto] It's gonna take a lot to drag me away from youuuuuu",
})