local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local CorePackages = game:GetService("CorePackages")
local Roact = dependencies.Roact
local Text = require(CorePackages.AppTempCommon.Common.Text)

local FitTextLabel = Roact.PureComponent:extend("FitTextLabel")
FitTextLabel.defaultProps = {
	maxWidth = 0,
	Text = "Text",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Color3.fromRGB(0, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
}

function FitTextLabel:init()
	self.rbx = Roact.createRef()

	self.onResize = function()
		local current = self.rbx.current
		if not current then
			return
		end

		local maxWidth = self.props.maxWidth
		local text = self.props.Text
		local font = self.props.Font
		local textSize = self.props.TextSize

		local textBounds = Text.GetTextBounds(text, font, textSize, Vector2.new(maxWidth, 1000))
		if maxWidth > 0 then
			current.Size = UDim2.new(
				UDim.new(0, math.min(maxWidth, textBounds.X)),
				UDim.new(0, textBounds.Y)
			)
		else
			current.Size = UDim2.new(
				UDim.new(0, textBounds.X),
				UDim.new(0, textBounds.Y)
			)
		end
	end
end

function FitTextLabel:render()
	local backgroundTransparency = self.props.BackgroundTransparency
	local text = self.props.Text
	local font = self.props.Font
	local textSize = self.props.TextSize
	local textXAlignment = self.props.TextXAlignment
	local textColor3 = self.props.TextColor3

	return Roact.createElement("TextLabel", {
		BackgroundTransparency = backgroundTransparency,
		Text = text,
		Font = font,
		TextSize = textSize,
		TextWrapped = true,
		TextXAlignment = textXAlignment,
		TextColor3 = textColor3,

		[Roact.Ref] = self.rbx,
		[Roact.Change.AbsoluteSize] = self.onResize,
		[Roact.Change.Text] = self.onResize,
	})
end

function FitTextLabel:didMount()
	self.onResize()
end

function FitTextLabel:didUpdate()
	self.onResize()
end

return FitTextLabel
