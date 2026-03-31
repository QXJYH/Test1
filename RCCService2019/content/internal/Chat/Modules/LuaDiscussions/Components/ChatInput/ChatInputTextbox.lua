local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local SOME_SORT_OF_WHITE_COLOR = Color3.fromRGB(200, 200, 200)

local ChatInputTextbox = Roact.PureComponent:extend("ChatInputTextbox")
ChatInputTextbox.defaultProps = {
	marginHeight = 0,
	marginLeft = 0,
	marginRight = 0,
	onFocusLost = nil,
}

function ChatInputTextbox:render()
	return UIBlox.Style.withStyle(function(style)
		local marginHeight = self.props.marginHeight
		local marginLeft = self.props.marginLeft
		local marginRight = self.props.marginRight
		local layoutOrder = self.props.LayoutOrder

		return Roact.createElement("TextBox", {
			[Roact.Ref] = self.props[Roact.Ref],
			[Roact.Event.FocusLost] = self.props.onFocusLost,
			ClearTextOnFocus = false,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(
				UDim.new(1, -(marginRight + marginLeft)),
				UDim.new(1, -marginHeight * 2)
			),
			--TODO: SOC-6205 PlaceholderText
			Text = "",
			LayoutOrder = layoutOrder,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = SOME_SORT_OF_WHITE_COLOR,
			PlaceholderColor3 = SOME_SORT_OF_WHITE_COLOR,
		})
	end)
end

return ChatInputTextbox
