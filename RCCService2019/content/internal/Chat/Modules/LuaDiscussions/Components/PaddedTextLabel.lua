local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact

local FitTextLabel = require(script.Parent.FitTextLabel)
local wrapFitBabies = require(script.Parent.wrapFitBabies)

local PaddedTextLabel = Roact.PureComponent:extend("PaddedTextLabel")
PaddedTextLabel.defaultProps = {
	Font = Enum.Font.Gotham,
	LayoutOrder = 0,
	PaddingBottom = 0,
	PaddingLeft = 0,
	PaddingRight = 0,
	PaddingTop = 0,
	Text = "Text",
	TextColor3 = Color3.fromRGB(0, 0, 0),
	TextSize = 32,
}

function PaddedTextLabel:render()
	local font = self.props.Font
	local layoutOrder = self.props.LayoutOrder
	local paddingBottom = self.props.PaddingBottom
	local paddingLeft = self.props.PaddingLeft
	local paddingRight = self.props.PaddingRight
	local paddingTop = self.props.PaddingTop
	local text = self.props.Text
	local textColor3 = self.props.TextColor3
	local textSize = self.props.TextSize

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = layoutOrder,
	},{
		layout = Roact.createElement("UIListLayout"),
		padding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, paddingBottom),
			PaddingLeft = UDim.new(0, paddingLeft),
			PaddingRight = UDim.new(0, paddingRight),
			PaddingTop = UDim.new(0, paddingTop),
		}),
		textLabel = Roact.createElement(FitTextLabel, {
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = textColor3,
			Font = font,
			TextSize = textSize,
		}),
	})
end

return wrapFitBabies(PaddedTextLabel)