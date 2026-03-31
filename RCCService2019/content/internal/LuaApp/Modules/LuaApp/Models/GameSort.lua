local Modules = game:GetService("CoreGui").RobloxGui.Modules
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

--[[
	{
		"token": string,
		"name": string,
		"displayName" : string,
		"timeOptionsAvailable": boolean,
		"genreOptionsAvailable": boolean,
		"numberOfRows": number,
		"isDefaultSort" : boolean
	}
]]

-- This is a static client-side mapping of icons that we want our sorts to use:
local ALL_GAME_ICONS

if UseNewAppStyle then
	ALL_GAME_ICONS = {
		default = "LuaApp/category/filter_default",

		Featured = "LuaApp/category/filter_featured",
		FriendActivity = "LuaApp/category/filter_friendsplaying",
		MyFavorite = "LuaApp/category/filter_myfavorites",
		MyRecent = "LuaApp/category/filter_continueplaying",
		Popular = "LuaApp/category/filter_popular",
		PopularInCountry = "LuaApp/category/filter_popularnearyou",
		TopGrossing = "LuaApp/category/filter_topearning",
		TopRated = "LuaApp/category/filter_toprated",
		TopRetaining = "LuaApp/category/filter_recommended",
	}
else
	-- TODO: remove the old icons when removing flag LuaAppEnableStyleProvider
	ALL_GAME_ICONS = {
		default = "LuaApp/category/ic-default",

		BuildersClub = "LuaApp/category/ic-bc",
		Featured = "LuaApp/category/ic-featured",
		FriendActivity = "LuaApp/category/ic-friend activity",
		MyFavorite = "LuaApp/category/ic-my favorite",
		MyRecent = "LuaApp/category/ic-my recent",
		Popular = "LuaApp/category/ic-popular",
		PopularInCountry = "LuaApp/category/ic-popular in country",
		PopularInVr = "LuaApp/category/ic-popular in VR",
		Purchased = "LuaApp/category/ic-purchased",
		TopFavorite = "LuaApp/category/ic-top favorite",
		TopGrossing = "LuaApp/category/ic-top earning",
		TopPaid = "LuaApp/category/ic-top paid",
		TopRated = "LuaApp/category/ic-top rated",
		TopRetaining = "LuaApp/category/ic-recommended",
	}
end

local GameSort = {}

function GameSort.new()
	local self = {}

	return self
end

function GameSort.mock()
	local self = GameSort.new()
	self.displayIcon = ""
	self.displayName = ""
	self.genreOptionsAvailable = false
	self.isDefaultSort = true
	self.name = ""
	self.numberOfRows = 1
	self.timeOptionsAvailable = false
	self.token = ""
	self.contextUniverseId = ""
	self.contextCountryRegionId = ""

	return self
end

function GameSort.fromJsonData(gameSortJson)
	local self = GameSort.new()
	self.displayName = gameSortJson.displayName
	self.genreOptionsAvailable = gameSortJson.genreOptionsAvailable
	self.isDefaultSort = gameSortJson.isDefaultSort
	self.name = gameSortJson.name
	self.numberOfRows = gameSortJson.numberOfRows
	self.timeOptionsAvailable = gameSortJson.timeOptionsAvailable
	self.token = gameSortJson.token
	self.contextUniverseId = gameSortJson.contextUniverseId
	self.contextCountryRegionId = gameSortJson.contextCountryRegionId
	self.gameSetTargetId = gameSortJson.gameSetTargetId

	-- Assign the icon:
	if self.name ~= nil then
		self.displayIcon = ALL_GAME_ICONS[self.name]
	end
	if self.displayIcon == nil then
		self.displayIcon = ALL_GAME_ICONS["default"]
	end

	return self
end

return GameSort
