local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local Roact = require(CorePackages.Roact)
local Modules = CoreGui.RobloxGui.Modules
local Constants = require(Modules.LuaApp.Constants)
local ChatConstants = require(Modules.LuaChat.Constants)
local Text = require(CorePackages.AppTempCommon.Common.Text)

-- Constants
local ROUNDED_BUTTON = "rbxasset://textures/ui/LuaChat/9-slice/input-default.png"
local GAME_TEXT_FONT = ChatConstants.Font.STANDARD
local GAME_TEXT_SIZE = 23

local ActionButton = Roact.PureComponent:extend("ActionButton")
ActionButton.defaultProps = {
    height = 32,
    colorButton = Constants.Color.GREEN_PRIMARY,
    colorText = Constants.Color.WHITE,
    text = "Button",
    textPadding = 5,
    onActivated = nil,
    layoutOrder = 1,
}

function ActionButton:render()
    local text = self.props.text

    local width = Text.GetTextWidth(text, GAME_TEXT_FONT, GAME_TEXT_SIZE)

    return Roact.createElement("ImageButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Image = ROUNDED_BUTTON,
        ImageColor3 = self.props.colorButton,
        LayoutOrder = self.props.layoutOrder,
        ScaleType = Enum.ScaleType.Slice,
        Size = UDim2.new(0, width + 2 * self.props.textPadding, 0, self.props.height),
        SliceCenter = Rect.new(3,3,4,4),
        [Roact.Event.Activated] = self.props.onActivated,
    }, {
        ActionLabel = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = GAME_TEXT_FONT,
            Size = UDim2.new(1, 0, 1, 0),
            Text = text,
            TextColor3 = self.props.colorText,
            TextSize = GAME_TEXT_SIZE,
        }),
    })
end

return ActionButton