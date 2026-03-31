--[[
	Creates a Roact wrapper for a loading button that has toggle icons.
	Props in addition to GenericButton:
		On : bool - Is the button on.
		OnIcon: content - The on icon of the button.
		OffIcon: content - The off icon of the button.
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
local GenericButton = require(Modules.LuaApp.Components.GenericButton)
local ButtonState = require(Modules.LuaApp.Enum.ButtonState)

local ToggleButton = Roact.PureComponent:extend("ToggleButton")

function ToggleButton:init()
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

function ToggleButton:willUpdate(nextProps, nextState)
	if self.props.StateChanged ~= nextProps.StateChanged then
		self.onStateChanged = function(currentState, nextState)
			self:setState({
				currentState = nextState,
			})
			if self.props.StateChanged then
				return self.props.StateChanged(currentState, nextState)
			end
		end
	end
end

function ToggleButton:render()
	local props = self.props
	local newProps = Immutable.RemoveFromDictionary(props, Roact.Children,
		"OnIcon", "OffIcon", "IconSize", "IconPosition", "IconAnchorPoint", "Theme")
	local theme = props.Theme
	local on = self.props.On
	local iconSize = self.props.IconSize or UDim2.new(1, 0, 1, 0)
	local iconPosition = self.props.IconPosition or UDim2.new(0.5, 0, 0.5, 0)
	local iconAnchorPoint = self.props.IconAnchorPoint or Vector2.new(0.5, 0.5)
	local currentState = self.state.currentState
	local iconImage
	local buttonTheme
	if on then
		iconImage = self.props.OnIcon
		buttonTheme = theme.On
	else
		iconImage = self.props.OffIcon
		buttonTheme = theme.Off
	end
	newProps.Theme = buttonTheme
	local defaultStateTheme = buttonTheme[ButtonState.Default]
	local currentStateTheme = buttonTheme[currentState] or defaultStateTheme
	local content = currentStateTheme.Content or defaultStateTheme.Content
	local iconColor = content.Color or defaultStateTheme.Content.Color
	local iconTransparency = content.Transparency or defaultStateTheme.Content.Transparency
	local buttonIcon = Roact.createElement(ImageSetLabel, {
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

return ToggleButton