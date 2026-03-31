local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local ChatBubbleContainer = require(Components.ChatMessage.ChatBubbleContainer)
local FitTextLabel = require(Components.FitTextLabel)

local SOME_LIGHT_WHITE_COLOR = Color3.fromRGB(200, 200, 200)

local PlainText = Roact.PureComponent:extend("PlainText")
PlainText.defaultProps = {
	maxWidth = 0,
	innerPadding = 0,
	messageChunk = {
		message = "",
	},
}

function PlainText:render()
	return UIBlox.Style.withStyle(function(style)
		local isIncoming = self.props.isIncoming
		local messageChunk = self.props.messageChunk
		local maxWidth = self.props.maxWidth
		local innerPadding = self.props.innerPadding

		local contentMaxWidth = math.max(0, maxWidth - innerPadding)

		local text = messageChunk.message

		return Roact.createElement(ChatBubbleContainer, {
			isIncoming = isIncoming,
			innerPadding = innerPadding,
		}, {
			textContent = Roact.createElement(FitTextLabel, {
				BackgroundTransparency = 1,
				maxWidth = contentMaxWidth,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = text,
				Font = Enum.Font.Gotham,
				TextSize = 18,
				TextColor3 = SOME_LIGHT_WHITE_COLOR,
			})
		})
	end)
end

return PlainText