local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelAnnouncement = require(Components.ChannelDetails.ChannelAnnouncement)

local SCREEN_SIZE = Vector2.new(800, 480)

return Roact.createElement("Frame", {
    Size = UDim2.new(0, SCREEN_SIZE.X, 0, SCREEN_SIZE.Y)
}, {
    layout = Roact.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
    channelAnnouncement = Roact.createElement(ChannelAnnouncement, {
        LayoutOrder = 1,
    }),
})
