local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local Constants = require(Modules.LuaApp.Constants)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)

local getUnreadConversationCount = require(Modules.LuaChat.Utils.getUnreadConversationCount)

local FONT_HEIGHT = Constants.HomePagePanelProps.WidgetContentText.Size

local UnreadChatMessagesLabel = Roact.PureComponent:extend("UnreadChatMessagesLabel")

function UnreadChatMessagesLabel:render()
	local theme = self._context.AppTheme
	local unreadConversationCount = self.props.unreadConverstionCount

	return Roact.createElement(LocalizedTextLabel, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, FONT_HEIGHT),
		TextColor3 = theme.Widget.ContentText.Color,
		TextSize = FONT_HEIGHT,
		Text = {"Feature.Chat.UnreadMessagesWidget", NUMBER_OF_UNREAD_MESSAGES = unreadConversationCount},
		Font = theme.Widget.ContentText.Font,
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			unreadConverstionCount = getUnreadConversationCount(state.ChatAppReducer.Conversations),
		}
	end
)(UnreadChatMessagesLabel)