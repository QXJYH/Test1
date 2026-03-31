local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local PaddedTextLabel = require(Components.PaddedTextLabel)

local ChannelListItem = Roact.PureComponent:extend("ChannelListItem")
ChannelListItem.defaultProps = {
    mainText = "MainText",
    subText = "Subtext",
    LayoutOrder = 0,
}

-- styling stuff here
local SUBTEXT_COLOR = Color3.fromRGB(200,200,200)
local CHANNEL_TITLE_COLOR = Color3.fromRGB(222,222,222)
local BACKGROUND_COLOR = Color3.fromRGB(111,111,111)

function ChannelListItem:render()
    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = BACKGROUND_COLOR,
        LayoutOrder = self.props.LayoutOrder
    }, {
        layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        mainText = Roact.createElement(PaddedTextLabel, {
            Font = Enum.Font.SourceSansBold,
            Text = self.props.mainText,
            TextColor3 = CHANNEL_TITLE_COLOR,
            TextSize = 22,
            PaddingLeft = 10,
            PaddingTop = 6,
            LayoutOrder = 1,
        }),
        subText = Roact.createElement(PaddedTextLabel, {
            Font = Enum.Font.SourceSans,
            Text = self.props.subText,
            TextSize = 22,
            TextColor3 = SUBTEXT_COLOR,
            PaddingLeft = 10,
            PaddingBottom = 6,
            LayoutOrder = 2,
        })
    })
end

return ChannelListItem