--[[
	Creates a Roact wrapper component that is a generic text button with states.
		If an image is not provided the background color and background transparency will be set instead.
	Props in addition to GenericButton:
		Text : string - The text on the button.
		TextSizeMin : number - The min size of the text.
		TextSizeMax : number - the max size of the text.
		TextXAlignment : Enum.TextXAlignment - Determines the horizontal alignment of rendered text. Default: center.
		TextYAlignment : Enum.TextYAlignment - Determines the vertical alignment of rendered text. Default: center.
		Theme : ButtonThemeDictionary : A map of theme configurations that this component uses.
]]

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local ButtonState = require(Modules.LuaApp.Enum.ButtonState)

local GenericButton = require(Modules.LuaApp.Components.GenericButton)

local TextButton = Roact.PureComponent:extend("TextButton")

local BUTTON_TEXT_SIZE = 24

function TextButton:init()
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

function TextButton:render()
	local props = self.props
	local theme = props.Theme
	local text = self.props.Text
	local textSizeMin = self.props.TextSizeMin
	local textSizeMax = self.props.TextSizeMax
	local textXAlignment = self.props.TextXAlignment
	local textYAlignment = self.props.TextYAlignment
	local currentState = self.state.currentState
	local defaultStateTheme = theme[ButtonState.Default]
	local currentStateTheme = theme[currentState] or defaultStateTheme
	local content = currentStateTheme.Content or defaultStateTheme.Content
	local textColor = content.Color or defaultStateTheme.Content.Color
	local textTransparency = content.Transparency or defaultStateTheme.Content.Transparency
	local textFont = theme.TextFont

	local newProps = Immutable.RemoveFromDictionary(props, Roact.Children,
		"Text", "TextSizeMin", "TextSizeMax", "TextXAlignment", "TextYAlignment")
	newProps.StateChanged = self.onStateChanged
	local buttonText
	if text then
		buttonText = Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = text,
			TextScaled = true,
			Font = textFont,
			TextColor3 = textColor,
			TextTransparency = textTransparency,
			TextXAlignment = textXAlignment or Enum.TextXAlignment.Center,
			TextYAlignment = textYAlignment or Enum.TextYAlignment.Center,
		},{
			Roact.createElement("UITextSizeConstraint", {
				MinTextSize = textSizeMin,
				MaxTextSize = textSizeMax or BUTTON_TEXT_SIZE,
			})
		})
	end
	return Roact.createElement(GenericButton, newProps,
		Immutable.JoinDictionaries(props[Roact.Children] or {}, {ButtonText = buttonText})
	)
end

return TextButton