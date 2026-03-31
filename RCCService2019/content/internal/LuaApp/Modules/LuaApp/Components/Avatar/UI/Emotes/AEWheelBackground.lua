local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local Emotes = script.Parent

local SlotHighlight = require(Emotes.AESlotHighlight)

local WheelBackground = Roact.PureComponent:extend("WheelBackground")

function WheelBackground:render()
    local deviceOrientation = self.props.deviceOrientation

	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo =  self._context.AvatarEditorTheme.EmotesWheel:getThemeInfo(deviceOrientation, themeName)

    return Roact.createElement("Folder", {}, {
        CircleImage = Roact.createElement("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = themeInfo.OrientationTheme.CircleImage,
            ZIndex = 1,
        }),

        SlotHighlight = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 2,
        }, {
            Highlight = Roact.createElement(SlotHighlight, {
                deviceOrientation = deviceOrientation,
            })
        }),
    })
end

return WheelBackground