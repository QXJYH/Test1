--[[
	Model for an Asset (e.g. Hat).
	{
		name = string,
		description = string,
		bundleType = number,
		assetId = number,

		items = table of tables
			Example: {
				{
					owned = "",
					id = "",
					name = "",
					type = "",
				}
			},
		creator = {
			id = number,
			name = string,
			type = string,
		},
		priceInRobux = number or nil,
		isPublicDomain = bool,
		product = {
			id = number,
			type = string

			isForSale = bool,
		}
		thumbnails = {
			["150"] = string,
			["420"] = string,
		}
	}
]]
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local MockId = require(Modules.LuaApp.MockId)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local BundleInfo = {}

function BundleInfo.new()
	local self = {}

	return self
end

function BundleInfo.mock()
	local self = BundleInfo.new()

	self.receivedMarketPlaceInfo = false
	self.receivedOnlyThumbData = false

	self.name = ""
	self.description = ""
	self.bundleType = ""

	self.items = {}

	self.creator = {
		id = MockId(),
		name = "",
		type = "",
	}

	self.priceInRobux = 1
	self.isPublicDomain = true
	self.product = {
		id = MockId(),
		type = "",
		isForSale = true,
	}

	self.thumbnails = {}
	return self
end

local function getRobuxPrice(priceInRobux, isPublicDomain)
	if not priceInRobux and isPublicDomain then
		priceInRobux = 0
	end
	return priceInRobux
end

function BundleInfo.fromMulitgetBundle(bundleInfo)
	local bundleTable = BundleInfo.new()

	bundleTable.receivedMarketPlaceInfo = true
	bundleTable.receivedOnlyThumbData = false

	bundleTable.name = bundleInfo.name
	bundleTable.description = bundleInfo.description
	bundleTable.bundleType = bundleInfo.bundleType
	bundleTable.items = bundleInfo.items

	if bundleInfo.creator ~= nil then
		bundleTable.creator = {
			id = tostring(bundleInfo.creator.id),
			name = bundleInfo.creator.name,
			type = bundleInfo.creator.type,
			targetId = bundleInfo.creator.targetId,
		}
	end

	if bundleInfo.product ~= nil then
		-- PriceInRobux and isPublicDomain are separate from the product
		-- to remove inconsistencies between BundleInfo and AssetInfo
		bundleTable.isPublicDomain = bundleInfo.product.isPublicDomain == true
		bundleTable.priceInRobux = getRobuxPrice(bundleInfo.product.priceInRobux, bundleInfo.product.isPublicDomain)
		bundleTable.product = {
			id = tostring(bundleInfo.product.id),
			type = bundleInfo.product.type,
			isForSale = bundleInfo.product.isForSale,
		}
	end

	bundleTable.thumbnails = {}

	return bundleTable
end

function BundleInfo.fromGetThumbnail(thumbData)
	ArgCheck.isType(thumbData, "table", "thumbData must be a table.")
	local bundleTable = BundleInfo.new()

	bundleTable.receivedMarketPlaceInfo = false
	bundleTable.receivedOnlyThumbData = true

	bundleTable.name = ""
	bundleTable.description = ""
	bundleTable.bundleType = ""
	bundleTable.items = {}

	bundleTable.creator = {
		id = "",
		name = "",
		type = "",
	}
	bundleTable.priceInRobux = nil
	bundleTable.isPublicDomain = nil
	bundleTable.product = {
		id = "",
		type = "",
	}

	bundleTable.thumbnails = {}
	bundleTable.thumbnails[tostring(thumbData.size)] = thumbData.url

	return bundleTable
end

function BundleInfo.updateBundleWithoutThumbnail(oldbundleInfo, newbundleInfo)
	oldbundleInfo.receivedMarketPlaceInfo = true
	oldbundleInfo.receivedOnlyThumbData = false

	oldbundleInfo.name = newbundleInfo.name
	oldbundleInfo.description = newbundleInfo.description
	oldbundleInfo.bundleType = newbundleInfo.bundleType
	oldbundleInfo.items = newbundleInfo.items

	if newbundleInfo.creator ~= nil then
		oldbundleInfo.creator = {
			id = tostring(newbundleInfo.creator.id),
			name = newbundleInfo.creator.name,
			type = newbundleInfo.creator.type,
		}
	end

	oldbundleInfo.priceInRobux = getRobuxPrice(newbundleInfo.priceInRobux, newbundleInfo.isPublicDomain)
	oldbundleInfo.isPublicDomain = newbundleInfo.isPublicDomain

	if newbundleInfo.product ~= nil then
		oldbundleInfo.product = {
			id = tostring(newbundleInfo.product.id),
			type = newbundleInfo.product.type,
		}
	end

	return oldbundleInfo
end

function BundleInfo.updateThumbnail(bundleInfo, thumbData)
	ArgCheck.isType(thumbData, "table", "thumbData must be a table.")
	bundleInfo.thumbnails[tostring(thumbData.size)] = thumbData.url

	return bundleInfo
end

return BundleInfo