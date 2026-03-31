local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local GenericHeader = require(Components.ChatHeader.GenericHeader)
local UIBlox = dependencies.UIBlox

local GradientImage = require(Components.ChatHeader.GradientImage)
local MoreDetailsButton = require(Components.ChatHeader.MoreDetailsButton)
local ChannelTitle = require(Components.ChatHeader.ChannelTitle)
local NavigateBackButton = require(Components.ChatHeader.NavigateBackButton)

local ChannelChatHeader = Roact.PureComponent:extend("ChannelChatHeader")
ChannelChatHeader.defaultProps = {
	systemStatusBarHeight = 32,
	channelBackgroundImage = "",
	channelTitle = "channel",
	navigateBackFunction = nil,
	moreDetailsFunction = nil,
}

function ChannelChatHeader:render()
	return UIBlox.Style.withStyle(function(style)
		local systemStatusBarHeight = self.props.systemStatusBarHeight
		local channelBackgroundImage = self.props.channelBackgroundImage
		local channelTitle = self.props.channelTitle
		local moreDetailsFunction = self.props.moreDetailsFunction
		local navigateBackFunction = self.props.navigateBackFunction

		local leftChildren = {
			navigateBackButton = Roact.createElement(NavigateBackButton, {
				onActivated = navigateBackFunction,
				LayoutOrder = 1,
			}),
			channelTitle = Roact.createElement(ChannelTitle, {
				title = channelTitle,
				LayoutOrder = 2,
			}),
		}

		local rightChildren = {
			moreDetailsButton = Roact.createElement(MoreDetailsButton, {
				onActivated = moreDetailsFunction,
			}),
		}

		local headerType = GenericHeader("channelChat", leftChildren, nil, rightChildren)
		return Roact.createElement(GradientImage, {
			backgroundImage = channelBackgroundImage,
		}, {
			header = Roact.createElement(headerType, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -systemStatusBarHeight),
				Position = UDim2.new(0, 0, 0, systemStatusBarHeight),
			})
		})
	end)
end

return ChannelChatHeader
