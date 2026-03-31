local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelDetailsHeader = require(Components.ChannelDetails.ChannelDetailsHeader)

local SCREEN_SIZE = Vector2.new(800,480)

return Roact.createElement("Frame", {
    Size = UDim2.new(0, SCREEN_SIZE.X, 0, SCREEN_SIZE.Y)
}, {
    layout = Roact.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
    channelDetails = Roact.createElement(ChannelDetailsHeader, {
        LayoutOrder = 1,
    }),
})
