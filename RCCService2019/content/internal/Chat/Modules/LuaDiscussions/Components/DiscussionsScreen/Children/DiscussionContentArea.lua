local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local DiscussionListItem = require(Components.DiscussionsScreen.Children.DiscussionListItem)

local DiscussionContainer = Roact.PureComponent:extend("DiscussionContainer")
DiscussionContainer.defaultProps = {
    discussionModels = {}
    -- expects the following per model:
    -- discussionID
    -- discussionIcon
    -- channelModels
        -- channelId
        -- mainText
        -- subText
}

function DiscussionContainer:render()
    local discussions = {
        Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    }
    for i, discussionModel in ipairs(self.props.discussionModels) do
        table.insert(discussions, Roact.createElement(DiscussionListItem, {
            channelModels = discussionModel.channelModels,
            discussionId = discussionModel.discussionId,
            discussionIcon = discussionModel.discussionIcon,
            discussionBackground = discussionModel.discussionIcon,
            LayoutOrder = i,
        }))
    end

    return Roact.createElement("ScrollingFrame", {
       Size = UDim2.new(1, 0, 1, 0),
    }, discussions)
end

return DiscussionContainer