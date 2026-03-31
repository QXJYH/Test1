local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEAddRecentAsset = require(Modules.LuaApp.Actions.AEActions.AEAddRecentAsset)
local AERevokeAsset = require(Modules.LuaApp.Actions.AEActions.AERevokeAsset)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local Immutable = require(Modules.Common.Immutable)

local MAX_RECENT_ASSETS = 100

--[[
	Move this asset to the front of the list, or create a new list if empty.
	This recreates the list from scratch for Immutability.
]]
local function createOrMoveToFrontOfList(list, assetId, assetTypeId)
	local newState = {}

	local size = #list < MAX_RECENT_ASSETS + 1 and #list or MAX_RECENT_ASSETS + 1

	if assetTypeId ~= AEConstants.OUTFITS then
		newState[1] = assetId
	end

	for i = 1, size do
		local asset = list[i]
		local numAssets = #newState

		if assetId ~= asset and numAssets < MAX_RECENT_ASSETS then
			newState[numAssets + 1] = asset
		end
	end

	return newState
end

return function(state, action)
	state = state or {}

	if action.type == AEAddRecentAsset.name then
		if action.initialize then
			local newState = {}
			for _, assetId in pairs(action.assets) do
				newState[#newState + 1] = tostring(assetId)
			end
			return newState
		end

		return createOrMoveToFrontOfList(state, action.assets[1].assetId, action.assets[1].assetTypeId)
	elseif action.type == AERevokeAsset.name then
		local assetId = tostring(action.assetId)
		return Immutable.RemoveValueFromList(state, assetId)
	end

	return state
end