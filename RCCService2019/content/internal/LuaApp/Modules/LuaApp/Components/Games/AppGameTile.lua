local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local memoize = require(Modules.Common.memoize)

local Requests = Modules.LuaApp.Http.Requests
local SponsoredGamesRecordClick = require(Requests.SponsoredGamesRecordClick)
local AppPage = require(Modules.LuaApp.AppPage)
local ItemTile = require(Modules.LuaApp.Components.Common.ItemTile)
local GameStats = require(Modules.LuaApp.Components.Games.GameStats)
local UserIconList = require(Modules.LuaApp.Components.UserIconList)
local sortFriendsByPresenceAndRecency = require(Modules.LuaApp.sortFriendsByPresenceAndRecency)
local OpenCentralOverlayForPlacesList = require(Modules.LuaApp.Thunks.OpenCentralOverlayForPlacesList)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local TITLE_TEXT_DEFAULT_LINE_COUNT = 2

local USER_ICON_HEIGHT = 24

local AppGameTile = Roact.PureComponent:extend("AppGameTile")

function AppGameTile:init()
	self.gameTileRef = Roact.createRef()

	self.getTilePosition = function()
		return self.gameTileRef.current.AbsolutePosition
	end

	self.onActivated = function()
		self.props.navigateDown({ name = AppPage.GameDetail, detail = self.props.universeId })

		-- Fire game detail analytics
		local index = self.props.index
		local reportGameDetailOpened = self.props.reportGameDetailOpened
		reportGameDetailOpened(index)

		-- Record sponsored game click
		local networking = self.props.networking
		local entry = self.props.entry
		local isSponsored = entry.isSponsored
		if isSponsored then
			SponsoredGamesRecordClick(networking, entry.adId)
		end
	end

	self.onFriendFooterActivated = function()
		if self.isMounted then
			local game = self.props.game
			local size = self.props.size
			self.props.openContextualMenu(game, size, self.getTilePosition())
		end
	end
end

function AppGameTile:render()
	--Input props
	local entry = self.props.entry
	local layoutOrder = self.props.layoutOrder
	local size = self.props.size
	local friendFooterEnabled = self.props.friendFooterEnabled

	--Store props
	local hasInGameFriends = self.props.hasInGameFriends
	local friendsInGame = self.props.friendsInGame
	local thumbnail = self.props.thumbnail
	local name = self.props.name
	local totalUpVotes = self.props.totalUpVotes
	local totalDownVotes = self.props.totalDownVotes

	local width = size.X
	local height = size.Y

	local stats = {
		isSponsored = entry.isSponsored,
		playerCount = entry.playerCount,
		totalUpVotes = totalUpVotes,
		totalDownVotes = totalDownVotes,
	}

	local displayFriendFooter = friendFooterEnabled and hasInGameFriends

	local titleTextLineCount = TITLE_TEXT_DEFAULT_LINE_COUNT
	local footer
	if displayFriendFooter then
		titleTextLineCount = 1
		footer = withStyle(function(stylePalette)
			local maskColor = stylePalette.Theme.BackgroundDefault.Color
			return Roact.createElement("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = self.onFriendFooterActivated,
			}, {
				UserIconList = Roact.createElement(UserIconList, {
					users = friendsInGame,
					width = width,
					height = USER_ICON_HEIGHT,
					maskColor = maskColor,
				})
			})
		end)
	else
		footer = Roact.createElement(GameStats, {
			stats = stats
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, width, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		[Roact.Ref] = self.gameTileRef,
	}, {
		Tile = Roact.createElement(ItemTile, {
			thumbnail = thumbnail,
			name = name,
			titleTextLineCount = titleTextLineCount,
			footer = footer,
			onActivated = self.onActivated,
		}),
	})
end

function AppGameTile:didMount()
	self.isMounted = true
end

function AppGameTile:willUnmount()
	self.isMounted = false
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

local getHasInGameFriends = memoize(function(localUserId, users, inGameUsers)
	if not localUserId or not users or not inGameUsers then
		return false
	end

	for _, userId in pairs(inGameUsers) do
		if userId ~= localUserId then
			local user = users[userId]
			if user and user.isFriend then
				return true
			end
		end
	end
	return false
end)

AppGameTile = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local universeId = props.entry.universeId
		local game = state.Games[universeId]
		return {
			game = game,
			universeId = universeId,
			name = game.name,
			totalUpVotes = game.totalUpVotes,
			totalDownVotes = game.totalDownVotes,
			thumbnail = state.GameThumbnails[universeId],
			hasInGameFriends = getHasInGameFriends(
				state.LocalUserId,
				state.Users,
				state.InGameUsersByGame[universeId]
			),
			friendsInGame = getSortedFriends(
				state.Users,
				state.InGameUsersByGame[universeId]
			),
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
			openContextualMenu = function(game, anchorSpaceSize, anchorSpacePosition)
				dispatch(OpenCentralOverlayForPlacesList(game, anchorSpaceSize, anchorSpacePosition))
			end,
		}
	end
)(AppGameTile)

AppGameTile = RoactServices.connect({
	networking = RoactNetworking,
})(AppGameTile)

return AppGameTile