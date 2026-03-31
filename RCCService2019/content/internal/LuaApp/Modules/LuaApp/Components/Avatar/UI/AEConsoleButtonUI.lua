local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)

local AEConsoleButtonUI = Roact.PureComponent:extend("AEConsoleButton")

function AEConsoleButtonUI:render()
	local position = self.props.position
	local size = self.props.size
	local textSize = self.props.textSize
	local text = self.props.text
	local image = self.props.image
	local buttonRef = self.props.buttonRef

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = position,
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
		[Roact.Ref] = buttonRef,
	}, {
		HintActionText = Roact.createElement(LocalizedTextLabel, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 100, 0.5, 0),
			Size = textSize,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.SourceSans,
			TextSize = 36,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = text,
			TextScaled = true,
			ZIndex = 6,
		} , {
			UISizeConstraint = Roact.createElement("UITextSizeConstraint", {
				MaxTextSize = 36,
			}),
		}),
		ButtonIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 83, 0, 83),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = image,
			ZIndex = 6,
		}),
	})
end

return AEConsoleButtonUI