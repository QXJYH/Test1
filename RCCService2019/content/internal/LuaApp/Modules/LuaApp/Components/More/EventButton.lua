local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local EVENT_BUTTON_HEIGHT = 90
local EVENT_IMAGE_PADDING_X = 20
local EVENT_IMAGE_PADDING_Y = 10

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local EventButton = Roact.PureComponent:extend("EventButton")

EventButton.defaultProps = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, EVENT_BUTTON_HEIGHT),
	LayoutOrder = 1,
}

function EventButton:init()
	self.onActivated = function()
		local onActivated = self.props.onActivated
		if onActivated then
			onActivated(self.props.context)
		end
	end
end

function EventButton:render()
	local theme = self._context.AppTheme

	local position = self.props.Position
	local size = self.props.Size
	local layoutOrder = self.props.LayoutOrder
	local image = self.props.Image

	local renderEventButton = function(backgroundStyle)
		return Roact.createElement("ImageButton", {
			Position = position,
			Size = size,
			BackgroundColor3 = backgroundStyle.Color,
			BackgroundTransparency = backgroundStyle.Transparency,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			LayoutOrder = layoutOrder,

			[Roact.Event.Activated] = self.onActivated,
		}, {
			Image = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -EVENT_IMAGE_PADDING_X*2, 1, -EVENT_IMAGE_PADDING_Y*2),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = image,
				ScaleType = Enum.ScaleType.Fit,
			})
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return renderEventButton(style.Theme.BackgroundUIDefault)
		end)
	else
		return renderEventButton(theme.MorePage.Button.Background.Default)
	end
end

return EventButton