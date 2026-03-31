local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local PaddedImageButton = require(Components.PaddedImageButton)
local PaddedTextLabel = require(Components.PaddedTextLabel)

local IconWithText = Roact.PureComponent:extend("IconWithText")

IconWithText.defaultProps = {
    Image = "",
    Text = "Probably don't make this too long",
    fullHeight = 80,
    imageHeight = 64,
    onActivated = nil,
    textHeight = 24,
}

function IconWithText:render()
    local fullHeight = self.props.fullHeight
    local imageHeight = self.props.imageHeight
    local textHeight = self.props.textHeight

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, fullHeight)
    }, {
        listLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
        }),
        image = Roact.createElement(PaddedImageButton, {
            paddingHeight = fullHeight - imageHeight,
            paddingWidth = fullHeight - imageHeight,
            Image = self.props.Image,
            Size = UDim2.new(0, fullHeight, 0, fullHeight),
            LayoutOrder = 1,
            [Roact.Event.Activated] = self.props.onActivated,
        }),
        text = Roact.createElement(PaddedTextLabel, {
            Text = self.props.Text,
            PaddingTop = (fullHeight - textHeight) / 2,
            PaddingBottom = (fullHeight - textHeight) / 2,
            TextSize = textHeight,
            Font = Enum.Font.SourceSansBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
        })
    })
end

return IconWithText