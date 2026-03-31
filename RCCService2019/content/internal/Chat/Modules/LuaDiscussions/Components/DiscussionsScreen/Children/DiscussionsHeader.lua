local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact

local Components = LuaDiscussions.Components
local GenericHeader = require(Components.ChatHeader.GenericHeader)
local PaddedTextLabel = require(Components.PaddedTextLabel)
local PaddedImageButton = require(Components.PaddedImageButton)
local DiscussionsHeader = Roact.PureComponent:extend("DiscussionsHeader")

local PLACEHOLDER_BACK_ICON = "rbxasset://textures/ui/LuaChat/icons/ic-back-android.png"
local DARK_BACKGROUND_COLOR = Color3.fromRGB(44, 44, 44)

DiscussionsHeader.defaultProps = {
    LayoutOrder = 1,
    onBack = function() end,
}

function DiscussionsHeader:render()
    local padding = 10
    local text = "Discussions"

    local headerType = GenericHeader("Group Discussions", {
        backButton = Roact.createElement(PaddedImageButton, {
            Image = PLACEHOLDER_BACK_ICON,
            Size = UDim2.new(0, 80, 0, 40),
            paddingWidth = padding,
            [Roact.Event.Activated] = self.props.onBack,
        })
    }, {
        headerText = Roact.createElement(PaddedTextLabel, {
            Font = Enum.Font.Gotham,
            PaddingBottom = padding,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 28,
            PaddingTop = padding,
        })
    })
    return Roact.createElement(headerType, {
        Size = UDim2.new(1, 0, 1, 0),
        LayoutOrder = self.props.LayoutOrder,
        BackgroundColor3 = DARK_BACKGROUND_COLOR,
    })
end

return DiscussionsHeader