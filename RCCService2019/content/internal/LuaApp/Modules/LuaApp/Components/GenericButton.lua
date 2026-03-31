--[[
	Creates a Roact wrapper component that is a generic text button with states.
		If an image is not provided the background color and background transparency will be set instead.
	Props in addition to LoadableButton:
		Theme : ButtonThemeDictionary : A map of theme configurations that this component uses.
		Example,
		{
			TextFont = Enum.Font.SourceSans,
			[ButtonState.Default] = {
				Background = {
					Color = Colors.Green,
					Transparency = 0,
				},
				Border = {
					Color = Colors.Green,
					Transparency = 0,
				},
				Content = {
					Color = Colors.White,
					Transparency = 0.3,
				},
			}
		}
]]
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ButtonState = require(Modules.LuaApp.Enum.ButtonState)

local LoadableButton = require(Modules.LuaApp.Components.LoadableButton)

local BACKGROUND_IMAGE_9_SLICE_FILL = "LuaApp/buttons/buttonFill"
local BACKGROUND_IMAGE_9_SLICE_BORDER = "LuaApp/buttons/buttonStroke"
local BACKGROUND_IMAGE_9_SLICE_CENTER = Rect.new(8, 8, 9, 9)

local GenericButton = Roact.PureComponent:extend("GenericButton")

function GenericButton:init()
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

function GenericButton:render()
	local props = self.props
	local theme = props.Theme
	assert(theme ~= nil, "A theme table must be provided.")
	assert(theme[ButtonState.Default] ~= nil, "Missing default state theme.")
	local currentState = self.state.currentState
	local defaultStateTheme = theme[ButtonState.Default]
	local currentStateTheme = theme[currentState] or defaultStateTheme
	local background = currentStateTheme.Background or defaultStateTheme.Background
	local backgroundColor = background.Color or defaultStateTheme.Background.Color
	local backgroundTransparency = background.Transparency or defaultStateTheme.Background.Transparency
	local border = currentStateTheme.Border or defaultStateTheme.Border
	local borderColor = border.Color or defaultStateTheme.Border.Color
	local borderTransparency = border.Transparency or defaultStateTheme.Border.Transparency

	local newProps = Immutable.RemoveFromDictionary(props, Roact.Children, "Theme")
	newProps.StateChanged = self.onStateChanged
	newProps.Image = BACKGROUND_IMAGE_9_SLICE_FILL
	newProps.ScaleType = Enum.ScaleType.Slice
	newProps.SliceCenter = BACKGROUND_IMAGE_9_SLICE_CENTER
	newProps.ImageColor3 = backgroundColor
	newProps.ImageTransparency = backgroundTransparency
	newProps.BackgroundTransparency = 1
	local borderImage = Roact.createElement(ImageSetLabel,{
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = BACKGROUND_IMAGE_9_SLICE_BORDER,
		ImageColor3 = borderColor,
		ImageTransparency = borderTransparency,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = BACKGROUND_IMAGE_9_SLICE_CENTER,
	})
	return Roact.createElement(LoadableButton, newProps,
		Immutable.JoinDictionaries(props[Roact.Children] or {}, {ButtonBorder = borderImage})
	)
end

return GenericButton