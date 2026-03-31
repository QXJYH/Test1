local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AESetOwnedAssets = require(Modules.LuaApp.Actions.AEActions.AESetOwnedAssets)
local AEGrantAsset = require(Modules.LuaApp.Actions.AEActions.AEGrantAsset)
local AERevokeAsset = require(Modules.LuaApp.Actions.AEActions.AERevokeAsset)
local AEGrantOutfit = require(Modules.LuaApp.Actions.AEActions.AEGrantOutfit)
local AERevokeOutfit = require(Modules.LuaApp.Actions.AEActions.AERevokeOutfit)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local Immutable = require(Modules.Common.Immutable)
local FFlagAvatarEditorCostumeSignalR = settings():GetFFlag("AvatarEditorCostumeSignalR")

--[[
	Add more owned asset ids to the players list. Keep order by checking for duplicates and only
	appending new ones to the list.
]]
return function(state, action)
	state = state or {}

	if action.type == AESetOwnedAssets.name then
		local checkForDups = {}
		local currentAssets = state[action.assetTypeId] and state[action.assetTypeId] or {}

		for _, assetId in pairs(currentAssets) do
			checkForDups[assetId] = assetId
		end

		for _, assetId in pairs(action.assets) do
			if not checkForDups[assetId] then
				currentAssets[#currentAssets + 1] = assetId
			end
		end

		return Immutable.Set(state, action.assetTypeId, currentAssets)
	elseif action.type == AEGrantAsset.name then
		local updatedAssets = {}
		local assetTypeId = tostring(action.assetTypeId)
		local assetId = tostring(action.assetId)
		local currentAssets = state[assetTypeId] and state[assetTypeId] or {}

		updatedAssets[1] = assetId

		for _, assetId in ipairs(currentAssets) do
			-- Do nothing if this asset is already owned.
			if assetId == action.assetId then
				return state
			else
				updatedAssets[#updatedAssets + 1] = assetId
			end
		end

		return Immutable.Set(state, assetTypeId, updatedAssets)
	elseif action.type == AERevokeAsset.name then
		local updatedAssets = {}
		local assetTypeId = tostring(action.assetTypeId)
		local assetToRevokeId = tostring(action.assetId)
		local currentAssets = state[assetTypeId] and state[assetTypeId] or {}

		for _, assetId in ipairs(currentAssets) do
			if assetId ~= assetToRevokeId then
				updatedAssets[#updatedAssets + 1] = assetId
			end
		end
		return Immutable.Set(state, assetTypeId, updatedAssets)

	elseif action.type == AEGrantOutfit.name and FFlagAvatarEditorCostumeSignalR then
		local currentOutfits = state[AEConstants.OUTFITS] or {}
		local actionOutfitId = tostring(action.outfitId)

		for _, outfitId in ipairs(currentOutfits) do
			-- Do nothing if this costume is already owned.
			if outfitId == actionOutfitId then
				return state
			end
		end
		currentOutfits[#currentOutfits + 1] = actionOutfitId
		return Immutable.Set(state, AEConstants.OUTFITS, currentOutfits)

	elseif action.type == AERevokeOutfit.name and FFlagAvatarEditorCostumeSignalR then
		local outfitId = tostring(action.outfitId)
		local currentOutfits = state[AEConstants.OUTFITS] or {}
		local updatedCostume = Immutable.RemoveValueFromList(currentOutfits, outfitId)

		return Immutable.Set(state, AEConstants.OUTFITS, updatedCostume)
	end

	return state
end