local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local HomePageWidget = require(Modules.LuaApp.Components.Home.HomePageWidget)
local UnreadChatMessagesLabel = require(Modules.LuaApp.Components.Chat.UnreadChatMessagesLabel)

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)

local PADDING_BOTTOM = UDim.new(0, 30)

local CHAT_ICON = "LuaApp/icons/chat"
local TITLE_KEY = "CommonUI.Features.Label.Chat"

local UnreadChatWidget = Roact.PureComponent:extend("UnreadChatWidget")

function UnreadChatWidget:init()
	self.onActivated = function()
		self.props.navigateToPage(AppPage.Chat)
	end
end

function UnreadChatWidget:render()
	local layoutOrder = self.props.layoutOrder

	return Roact.createElement(HomePageWidget, {
		layoutOrder = layoutOrder,
		icon = CHAT_ICON,
		titleKey = TITLE_KEY,
		renderContent = UnreadChatMessagesLabel,
		onActivated = self.onActivated,
		contentPadding = {
			PaddingBottom = PADDING_BOTTOM,
		},
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {}
	end,
	function(dispatch)
		return {
			navigateToPage = function(page)
				dispatch(NavigateToRoute({ { name = page } }))
			end,
		}
	end
)(UnreadChatWidget)