local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local ChannelTitle = Roact.PureComponent:extend("ChannelTitle")
ChannelTitle.defaultProps = {
	channelName = "channel",
}

function ChannelTitle:render()
	return UIBlox.Style.withStyle(function(style)
		local channelName = self.props.channelName
		local layoutOrder = self.props.LayoutOrder

		return Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 16,
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = style.Theme.TextDefault.Color,
			Transparency = style.Theme.TextDefault.Transparency,
			Text = string.format("#%s", channelName),
			LayoutOrder = layoutOrder,
		})
	end)
end

return ChannelTitle
