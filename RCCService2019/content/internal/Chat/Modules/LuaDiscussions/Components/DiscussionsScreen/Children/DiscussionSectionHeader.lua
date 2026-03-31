local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local IconWithText = require(Components.IconWithText)
local GenericHeader = require(Components.ChatHeader.GenericHeader)
local MoreDetailsButton = require(Components.ChatHeader.MoreDetailsButton)

local DiscussionSectionHeader = Roact.PureComponent:extend("DiscussionSectionHeader")
DiscussionSectionHeader.defaultProps = {
    discussionIcon = nil,
    discussionBackground = nil,
    onActivated = function() end,
    onActivatedImage = function() end,
    onActivatedMoreDetails = function() end,
    height = 100,
}

function DiscussionSectionHeader:render()

    local discussionHeader = GenericHeader("Discussions Header", {
        imageWithText = Roact.createElement(IconWithText, {
            Image = self.props.discussionIcon,
            onActivated = self.props.onActivatedImage,
        })
    },
    {}, -- center div intentionally left blank
    {
        moreDetailsButton = Roact.createElement(MoreDetailsButton, {
            onActivated = self.props.onActivatedMoreDetails,
        })
    })

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 0, self.props.height),
        Image = self.props.discussionBackground,
        ScaleType = Enum.ScaleType.Crop,
        LayoutOrder = 1,
        [Roact.Event.Activated] = self.props.onActivated,
    }, {
        discussionHeader = Roact.createElement(discussionHeader, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
        }),
    })
end

return DiscussionSectionHeader