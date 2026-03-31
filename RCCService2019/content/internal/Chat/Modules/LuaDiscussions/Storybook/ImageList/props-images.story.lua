local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelMembers = require(Components.ChannelDetails.ChannelMembers)

-- Constants
local SCREEN_SIZE = Vector2.new(800,480)

local function generateImages(num)
    local tbl = {}
    for i = 1, num do
        table.insert(tbl, "rbxasset://textures/ui/LuaChat/icons/ic-profile.png")
    end
    return tbl
end

local images5 = generateImages(5)

return Roact.createElement("Frame", {
    Size = UDim2.new(0, SCREEN_SIZE.X, 0, SCREEN_SIZE.Y)
}, {
    layout = Roact.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
    channelMembers0 = Roact.createElement(ChannelMembers, {
        titleText = "0 memberList, 0 maxEntries",
        memberList = generateImages(0),
        maxEntries = 0,
        LayoutOrder = 1,
    }),
    channelMembers1 = Roact.createElement(ChannelMembers, {
        titleText = "1 memberList, 1 maxEntries",
        memberList = generateImages(1),
        maxEntries = 1,
        LayoutOrder = 2,
    }),
    channelMembers2 = Roact.createElement(ChannelMembers, {
        titleText = "1 memberList, 2 maxEntries",
        memberList = generateImages(1),
        maxEntries = 2,
        LayoutOrder = 3,
    }),
    channelMembers5 = Roact.createElement(ChannelMembers, {
        titleText = "5 memberList, 0 maxEntries (internal logic bumps to 1)",
        memberList = images5,
        maxEntries = 0,
        LayoutOrder = 4,
    }),
    channelMembers6 = Roact.createElement(ChannelMembers, {
        titleText = "5 memberList, 1 maxEntries",
        memberList = images5,
        maxEntries = 1,
        LayoutOrder = 5,
    }),
    channelMembers7 = Roact.createElement(ChannelMembers, {
        titleText = "7 memberList, 7 maxEntries",
        memberList = generateImages(7),
        maxEntries = 7,
        LayoutOrder = 6,
    }),
    channelMembers20 = Roact.createElement(ChannelMembers, {
        titleText = "20 memberList, 7 maxEntries",
        memberList = generateImages(20),
        maxEntries = 7,
        LayoutOrder = 7,
    }),

})
