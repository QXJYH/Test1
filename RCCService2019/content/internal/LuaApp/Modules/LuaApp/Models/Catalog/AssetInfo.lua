--[[
	Model for an Asset (e.g. Hat).
	{
		name = string,
		description = string,
		assetTypeId = number,
		assetId = number,

		priceInRobux = number,
		creator = {
			id = number,
			name = string,
			type = string,
			targetId = string,
		},
		created = string,
		updated = string,
		genre = string,
		minimumMembershipLevel = string,

		thumbnails = {
			["150"] = string,
			["420"] = string,
		}
	}
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local MockId = require(Modules.LuaApp.MockId)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local AssetInfo = {}

function AssetInfo.new()
	local self = {}

	return self
end

function AssetInfo.mock()
	local self = AssetInfo.new()

	self.receivedMarketPlaceInfo = false
	self.receivedOnlyThumbData = false

	self.name = ""
	self.description = ""
	self.creatorName = ""
	self.assetType = "0"
	self.assetId = MockId()

	self.priceInRobux = 1
	self.creator = {
		id = MockId(),
		name = "",
		type = "",
		targetId = "",
	}
	self.created = ""
	self.updated = ""
	self.genre = ""
	self.minimumMembershipLevel = ""

	self.thumbnails = {
		-- ["150"] = "",
		-- ["420"] = "",
	}
	return self
end

function AssetInfo.fromMarketplaceService(assetInfo)
	local assetTable = AssetInfo.new()

	assetTable.receivedMarketPlaceInfo = true
	assetTable.receivedOnlyThumbData = false

	assetTable.name = assetInfo.Name
	assetTable.description = assetInfo.Description
	assetTable.creatorName = assetInfo.Creator.Name
	assetTable.assetId = tostring(assetInfo.AssetId)
	assetTable.assetType = tostring(assetInfo.AssetTypeId)

	assetTable.priceInRobux = assetInfo.PriceInRobux
	assetTable.creator = {
		id = assetInfo.Creator.Id,
		name = assetInfo.Creator.Name,
		type = assetInfo.Creator.CreatorType,
		targetId = assetInfo.Creator.CreatorTargetId,
	}
	assetTable.created = assetInfo.Created
	assetTable.updated = assetInfo.Updated
	assetTable.genre = assetInfo.genre
	assetTable.minimumMembershipLevel = assetInfo.MinimumMembershipLevel
	assetTable.thumbnails = {}

	return assetTable
end

function AssetInfo.fromGetThumbnail(thumbData)
	ArgCheck.isType(thumbData, "table", "thumbData must be a table.")
	local assetTable = AssetInfo.new()

	assetTable.receivedMarketPlaceInfo = false
	assetTable.receivedOnlyThumbData = true

	assetTable.name = ""
	assetTable.description = ""
	assetTable.creatorName = ""
	assetTable.assetId = ""
	assetTable.assetType = ""
	assetTable.priceInRobux = ""
	assetTable.creator = {
		id = "",
		name = "",
		type = "",
		targetId = "",
	}
	assetTable.created = ""
	assetTable.updated = ""
	assetTable.genre = ""
	assetTable.minimumMembershipLevel = ""

	local thumbnails = {}
	thumbnails[tostring(thumbData.size)] = thumbData.url
	assetTable.thumbnails = thumbnails

	return assetTable
end

function AssetInfo.updateThumbnail(assetInfo, thumbData)
	ArgCheck.isType(thumbData, "table", "thumbData must be a table.")

	assetInfo.thumbnails[tostring(thumbData.size)] = thumbData.url

	return assetInfo
end

return AssetInfo