--[[
	Creates a Roact wrapper component that is a generic text button with states.
		If an image is not provided the background color and background transparency will be set instead.
	Props in addition to GenericButton:
		IconImage : Content - The icon on the button.
		IconSize : UDim2 = The size of the icon.
		IconPosition : UDim2 - The position of the icon. Optional. Default to center.
		IconAnchorPoint : UDim2 - The anchor point of the icon. Optional. Default to center.
		Theme : ButtonThemeDictionary : A map of theme configurations that this component uses.
]]

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ButtonState = require(Modules.LuaApp.Enum.ButtonState)

local GenericButton = require(Modules.LuaApp.Components.GenericButton)

local IconButton = Roact.PureComponent:extend("IconButton")


function IconButton:init()
	self.state = {
		currentState = ButtonState.Default,
	}
	self.onStateChanged = function(currentState, nextState)
		self:setState({
			currentState = nextState,
		})
		if self.props.StateChanged then
			return self.props.StateChanged(currentState, nextState)
		end
	end
end

function IconButton:render()
	local props = self.props
	local theme = props.Theme
	local iconImage = props.IconImage
	local currentState = self.state.currentState
	local defaultStateTheme = theme[ButtonState.Default]
	local currentStateTheme = theme[currentState] or defaultStateTheme
	local content = currentStateTheme.Content or defaultStateTheme.Content
	local iconColor = content.Color or defaultStateTheme.Content.Color
	local iconTransparency = content.Transparency or defaultStateTheme.Content.Transparency
	local newProps = Immutable.RemoveFromDictionary(props, Roact.Children,
		"IconImage", "IconSize", "IconPosition", "IconAnchorPoint")
	local iconSize = props.IconSize or UDim2.new(1, 0, 1, 0)
	local iconPosition = props.IconPosition or UDim2.new(0.5, 0, 0.5, 0)
	local iconAnchorPoint = props.IconAnchorPoint or Vector2.new(0.5, 0.5)
	local buttonIcon = Roact.createElement(ImageSetLabel,{
		Image = iconImage,
		Size = iconSize,
		Position = iconPosition,
		AnchorPoint = iconAnchorPoint,
		BackgroundTransparency = 1,
		ImageColor3 = iconColor,
		ImageTransparency = iconTransparency,
	})
	return Roact.createElement(GenericButton, newProps,
		Immutable.JoinDictionaries(props[Roact.Children] or {}, {ButtonIcon = buttonIcon})
	)
end

return IconButton