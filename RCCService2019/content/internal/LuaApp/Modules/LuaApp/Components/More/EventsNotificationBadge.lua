local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)

local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)

local EVENT_TEXT_FONT = Enum.Font.SourceSans
local EVENT_TEXT_SIZE = 17

local EventsNotificationBadge = Roact.PureComponent:extend("EventsNotificationBadge")

EventsNotificationBadge.defaultProps = {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, 0, 0.5, 0),
	TextColor3 = Constants.Color.GRAY3,
}

function EventsNotificationBadge:render()
	local anchorPoint = self.props.AnchorPoint
	local position = self.props.Position
	local textColor3 = self.props.TextColor3
	local textTransparency = self.props.TextTransparency
	local badgeCount = self.props.badgeCount

	if type(badgeCount) ~= "number" or badgeCount <= 0 then
		return nil
	end

	return Roact.createElement(FitTextLabel, {
		AnchorPoint = anchorPoint,
		Position = position,
		Size = UDim2.new(0, 0, 0, EVENT_TEXT_SIZE),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = EVENT_TEXT_FONT,
		Text = badgeCount,
		TextSize = EVENT_TEXT_SIZE,
		TextColor3 = textColor3,
		TextTransparency = textTransparency,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,

		fitAxis = FitChildren.FitAxis.Width,
	})
end

return EventsNotificationBadge