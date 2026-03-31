local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local memoize = require(Modules.Common.memoize)
local UserIconList = require(Modules.LuaApp.Components.UserIconList)
local sortFriendsByPresenceAndRecency = require(Modules.LuaApp.sortFriendsByPresenceAndRecency)

local FriendFooter = Roact.PureComponent:extend("FriendFooter")

FriendFooter.defaultProps = {
	innerMargin = 0,
	outerMargin = 0,
	titleTextSize = 0,
	footerContentWidth = 0,
	footerContentHeight = 0,
	friends = {},
	gameName = "",
}

function FriendFooter:render()
	local theme = self._context.AppTheme

	local innerMargin = self.props.innerMargin
	local outerMargin = self.props.outerMargin
	local titleTextSize = self.props.titleTextSize
	local footerContentWidth = self.props.footerContentWidth
	local footerContentHeight = self.props.footerContentHeight
	local friends = self.props.friends
	local gameName = self.props.gameName

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, innerMargin),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, outerMargin),
			PaddingRight = UDim.new(0, outerMargin),
			PaddingTop = UDim.new(0, outerMargin),
		}),
		Title = Roact.createElement("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, titleTextSize),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextSize = titleTextSize,
			TextColor3 = theme.GameCard.Title.Color,
			Font = theme.GameCard.Title.Font,
			Text = gameName,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, -- Center sinks the text down by 2 pixels
		}),
		UserIconList = Roact.createElement(UserIconList, {
			layoutOrder = 2,
			width = footerContentWidth,
			height = footerContentHeight,
			users = friends,
		}),
	})
end

--[[
	Takes in a set of userIds and returns their user info, sorted.

	Args:
		allUsers - list of all users stored in the Rodux store.
		mapOfUserIds - a set of userIds that are to be sorted and returned.
]]
local getSortedFriends = memoize(function(allUsers, mapOfUserIds)
	if not allUsers or not mapOfUserIds then
		return {}
	end

	local allFriends = {}
	for _, userId in pairs(mapOfUserIds) do
		local user = allUsers[userId]
		if user and user.isFriend then
			table.insert(allFriends, user)
		end
	end
	table.sort(allFriends, sortFriendsByPresenceAndRecency)
	return allFriends
end)

FriendFooter = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local universeId = props.universeId
		assert(typeof(universeId) == "string", "universeId must be provided as a valid string.")

		local game = state.Games[universeId]
		local gameName = ""
		if game then
			gameName = game.name
		end

		return {
			friends = getSortedFriends(
				state.Users,
				state.InGameUsersByGame[universeId]
			),
			gameName = gameName,
		}
	end
)(FriendFooter)

return FriendFooter