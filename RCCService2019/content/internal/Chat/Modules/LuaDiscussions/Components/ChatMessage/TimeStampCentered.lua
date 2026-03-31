local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local CorePackages = game:GetService("CorePackages")
local Roact = dependencies.Roact
local DateTime = require(CorePackages.AppTempCommon.LuaChat.DateTime)
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local SOME_LIGHT_GREYISH_COLOR = Color3.fromRGB(189, 190, 190)

local PaddedTextLabel = require(Components.PaddedTextLabel)

local TimeStampCentered = Roact.PureComponent:extend("TimeStampCentered")
TimeStampCentered.defaultProps = {
    isoTime = "1997-04-20T12:34:56Z",
    layoutOrder = 0,
}

function TimeStampCentered:render()
	return UIBlox.Style.withStyle(function(style)
	    local isoTime = self.props.isoTime
	    local fontHeight = 12
	    local verticalPadding = 2
	    local height = fontHeight + verticalPadding * 2

	    local dateTime = DateTime.fromIsoDate(isoTime)

	    return Roact.createElement("Frame", {
	        Size = UDim2.new(1, 0, 0, height),
	        BackgroundTransparency = 1,
	        LayoutOrder = self.props.layoutOrder,
	    }, {
	        layout = Roact.createElement("UIListLayout", {
	            HorizontalAlignment = Enum.HorizontalAlignment.Center,
	        }),
	        text = Roact.createElement(PaddedTextLabel, {
	            Font = Enum.Font.Gotham,
	            PaddingBottom = verticalPadding,
	            Text = dateTime.GetLongRelativeTime(dateTime),
	            TextColor3 = SOME_LIGHT_GREYISH_COLOR,
	            TextSize = fontHeight,
	            PaddingTop = verticalPadding,
	        })
	    })
	end)
end

return TimeStampCentered