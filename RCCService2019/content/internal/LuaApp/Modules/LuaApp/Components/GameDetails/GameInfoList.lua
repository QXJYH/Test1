local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ContentProvider = game:GetService("ContentProvider")
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local GameInfoRow = require(Modules.LuaApp.Components.GameDetails.GameInfoRow)
local DateTime = require(Modules.LuaChat.DateTime)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local BaseUrl = ContentProvider.BaseUrl

local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
local FFlagLuaHttpUrlBuilder = settings():GetFFlag("LuaHttpUrlBuilder")
local FFlagLuaAppGameDetailsHideEmptySections = settings():GetFFlag("LuaAppGameDetailsHideEmptySections")

local ROW_HEIGHT = 53

local CREATOR_URL_FORMATTER =
{
	["User"] = function(id)
		return string.format("%s/users/%s/profile", BaseUrl, tostring(id))
	end,
	["Group"] = function(id)
		return string.format("%s/groups/%s", BaseUrl, tostring(id))
	end,
}

local GameInfoList = Roact.PureComponent:extend("GameInfoList")

GameInfoList.defaultProps = {
	leftPadding = 0,
	rightPadding = 0,
}

local function createCreatorUrl(creatorId, creatorType)
	if FlagSettings:IsLuaGameDetailsPolish367Enabled() then
		local formatter = CREATOR_URL_FORMATTER[creatorType]
		if formatter then
			return formatter(creatorId)
		else
			-- Todo: send this warning message up to analytics so that we know when
			-- we are getting creatorTypes that aren't supported
			warn(string.format("%s - unknown creatorType of %s", tostring(script.name), tostring(creatorType)))
			return nil
		end
	else
		return BaseUrl .. "/users/" .. creatorId .. "/profile"
	end
end

function GameInfoList:makeGameInfoListData()
	local universeId = self.props.universeId
	local maxPlayers = self.props.gameDetail.maxPlayers
	local creatorId = self.props.gameDetail.creator.id
	local creatorType = self.props.gameDetail.creator.type
	local creatorName = self.props.gameDetail.creator.name
	local genre = self.props.gameDetail.genre
	local created = DateTime.fromIsoDate(self.props.gameDetail.created)
	local lastUpdated = DateTime.fromIsoDate(self.props.gameDetail.updated)
	local showPasses = self.props.showPasses
	local showBadges = self.props.showBadges

	self.gameInfoListData = {}
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.Developer",
		infoData = creatorName,
		linkPage = FFlagLuaHttpUrlBuilder and UrlBuilder.game.info.creator({
				creatorType = creatorType,
				creatorId = creatorId,
			}) or createCreatorUrl(creatorId, creatorType),
		analyticsSubPage = "Developer",
	})
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.MaxPlayers",
		infoData = tostring(maxPlayers),
	})
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.Genre",
		infoData = genre,
	})
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.Created",
		infoData = created:Format("M/D/YYYY"),
	})
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.Updated",
		infoData = lastUpdated:Format("M/D/YYYY"),
	})
	if showPasses then
		table.insert(self.gameInfoListData, {
			infoName = "Feature.GameDetails.Label.PassesAndGear",
			infoData = "",
			linkPage = FFlagLuaHttpUrlBuilder and UrlBuilder.game.info.store({
					universeId = universeId,
				}) or BaseUrl .. "/games/store-section/" .. universeId,
			analyticsSubPage = "PassesAndGear",
		})
	end
	if showBadges then
		table.insert(self.gameInfoListData, {
			infoName = "CommonUI.Features.Label.Badges",
			infoData = "",
			linkPage = FFlagLuaHttpUrlBuilder and UrlBuilder.game.info.badges({
					universeId = universeId
				}) or BaseUrl .. "/games/badges-section/" .. universeId,
			analyticsSubPage = "Badges",
		})
	end
	table.insert(self.gameInfoListData, {
		infoName = "Feature.GameDetails.Label.Servers",
		infoData = "",
		linkPage = FFlagLuaHttpUrlBuilder and UrlBuilder.game.info.servers({
				universeId = universeId
			}) or BaseUrl .. "/games/servers-section/" .. universeId,
		analyticsSubPage = "Servers",
	})
end

function GameInfoList:render()
	self:makeGameInfoListData()

	local rootPlaceId = self.props.gameDetail.rootPlaceId

	local listTheme = self._context.AppTheme.GameDetails.GameInfoList
	local layoutOrder = self.props.LayoutOrder
	local leftPadding = self.props.leftPadding
	local rightPadding = self.props.rightPadding

	local listContents = {}

	listContents["Layout"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	})

	local rowCount = 0
	for i, item in ipairs(self.gameInfoListData) do
		rowCount = rowCount + 1
		local hasDivider = i < #self.gameInfoListData
		listContents["GameInfoRow" .. i] = Roact.createElement(GameInfoRow, {
			Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			LayoutOrder = rowCount,
			placeId = rootPlaceId,
			infoName = item.infoName,
			infoData = item.infoData,
			linkPage = item.linkPage,
			leftPadding = leftPadding,
			rightPadding = rightPadding,
			analyticsSubPage = item.analyticsSubPage,
		})
		if hasDivider then
			rowCount = rowCount + 1
			listContents["Divider" .. i] = Roact.createElement("Frame", {
				Size = UDim2.new(1, -leftPadding, 0, 1),
				BackgroundColor3 = listTheme.DividerColor,
				BorderSizePixel = 0,
				LayoutOrder = rowCount,
			})
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, leftPadding + rightPadding, 0, ROW_HEIGHT * #self.gameInfoListData),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		ClipsDescendants = false,
	}, listContents)
end

GameInfoList = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gamePasses = state.GamePasses[props.universeId]
		local gameBadges = state.GameBadges[props.universeId]
		local showPasses = true
		local showBadges = true
		if FFlagLuaAppGameDetailsHideEmptySections then
			if gamePasses and #gamePasses == 0 then
				showPasses = false
			end
			if gameBadges and #gameBadges == 0 then
				showBadges = false
			end
		end
		return {
			gameDetail = state.GameDetails[props.universeId],
			showPasses = showPasses,
			showBadges = showBadges,
		}
	end
)(GameInfoList)

return GameInfoList
