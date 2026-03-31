local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local AEConsoleWarningWidget = Roact.PureComponent:extend("AEConsoleWarningWidget")

local MAX_IMAGE_LENGTH = 580
local TEXT_PADDING = 24
local DEFAULT_IMAGE_HEIGHT = 36 + TEXT_PADDING * 2

function AEConsoleWarningWidget:init()
	self.imageRef = Roact.createRef()
end

function AEConsoleWarningWidget:didUpdate(prevProps)
	local warningInformation = self.props.warningInformation[1]

	if warningInformation and prevProps.warningInformation[1] == warningInformation and
		self.props.fullView ~= prevProps.fullView and self.imageRef.current then
		self.imageRef.current.ImageTransparency = 0
		self.imageRef.current.ToastText.TextTransparency = 0
	end
end

function AEConsoleWarningWidget:render()
	local warning = self.props.warningInformation[1] or {}
	local fullView = self.props.fullView

	if warning.warningType and not fullView then
		return Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 680, 1, -171),
			Size = UDim2.new(0, MAX_IMAGE_LENGTH, 0, DEFAULT_IMAGE_HEIGHT),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = 'rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-tooltips.png',
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(8, 8, 9, 9),
			ZIndex = 6,
		}, {
			WarningText = Roact.createElement(LocalizedTextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, TEXT_PADDING, 0.5, 0),
				Size = UDim2.new(0, MAX_IMAGE_LENGTH - TEXT_PADDING * 2, 0, 36),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.SourceSans,
				TextSize = 36,
				TextColor3 = Color3.fromRGB(25, 25, 25),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Text = self.props.warningInformation[1]
					and self.props.warningInformation[1].text or 'Feature.Avatar.Message.NoNetworkConnection',
				TextWrapped = true,
				ZIndex = 6,
				TextScaled = true
			}, {
				UISizeConstraint = Roact.createElement("UITextSizeConstraint", {
					MaxTextSize = 36,
				}),
			}),
			Image = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 26, 0, DEFAULT_IMAGE_HEIGHT + 16),
				Size = UDim2.new(0, 32, 0, 16),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = 'rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-tip.png',
				ZIndex = 6,
			})
		})
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			warningInformation = state.AEAppReducer.AEWarningInformation,
			fullView = state.AEAppReducer.AEFullView,
		}
	end
)(AEConsoleWarningWidget)