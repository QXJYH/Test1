local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local DiscussionsHeader = require(Components.DiscussionsScreen.Children.DiscussionsHeader)
local DiscussionContentArea = require(Components.DiscussionsScreen.Children.DiscussionContentArea)
local RoactBlock = dependencies.RoactBlock

local DiscussionsScreenLayout = Roact.PureComponent:extend("DiscussionsScreenLayout")
DiscussionsScreenLayout.defaultProps = {
    screenSize = UDim2.new(0, 414, 0, 896),
    discussionModels = {}
}

function DiscussionsScreenLayout:render()
    return Roact.createElement("Frame", {
        Size = self.props.screenSize,
    }, RoactBlock.verticalLayout({
        RoactBlock.insert(
            UDim2.new(1, 0, 0, 100),
            Roact.createElement(DiscussionsHeader)
        ),
        RoactBlock.insert(
            UDim2.new(1, 0, 0, self.props.screenSize.Y.Offset - 100),
            Roact.createElement(DiscussionContentArea, {
                discussionModels = self.props.discussionModels,
            })
        ),
    }))
end

return DiscussionsScreenLayout