local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local Emotes = script.Parent

local WheelBackground = require(Emotes.AEWheelBackground)
local SlotNumbers = require(Emotes.AESlotNumbers)

local EmotesWheel = Roact.PureComponent:extend("EmotesWheel")

function EmotesWheel:render()
    local deviceOrientation = self.props.deviceOrientation

	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo =  self._context.AvatarEditorTheme.EmotesWheel:getThemeInfo(deviceOrientation, themeName)

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, {
        AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1,
        }),

        SizeConstraint = Roact.createElement("UISizeConstraint", {
            MinSize = themeInfo.OrientationTheme.EmotesWheelMinSize,
            MaxSize = themeInfo.OrientationTheme.EmotesWheelMaxSize,
        }),

        Back = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 1,
        }, {
            Background = Roact.createElement(WheelBackground, {
                deviceOrientation = deviceOrientation,
            }),
        }),

        Front = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 2,
        }, {
            SlotNumbers = Roact.createElement(SlotNumbers, {
                deviceOrientation = deviceOrientation,
            }),
        }),
    })
end

return EmotesWheel