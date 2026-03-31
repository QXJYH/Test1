local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local AESetOutfitInfo = require(Modules.LuaApp.Actions.AEActions.AESetOutfitInfo)
local AERevokeOutfit = require(Modules.LuaApp.Actions.AEActions.AERevokeOutfit)
local AEUpdateOutfit = require(Modules.LuaApp.Actions.AEActions.AEUpdateOutfit)
local FFlagAvatarEditorCostumeSignalR = settings():GetFFlag("AvatarEditorCostumeSignalR")

return function(state, action)
	state = state or {}

	if action.type == AESetOutfitInfo.name then
		return Immutable.Set(state, tostring(action.outfit.outfitId), action.outfit)
	elseif action.type == AERevokeOutfit.name and FFlagAvatarEditorCostumeSignalR then
		local outfitId = tostring(action.outfitId)
		return Immutable.RemoveFromDictionary(state, outfitId)

	elseif action.type == AEUpdateOutfit.name and FFlagAvatarEditorCostumeSignalR then
		-- To update outfit: remove the outfit info from the state. Because we
		-- don't remove it from AEOwnedAssets, its info will be regotten from the webapi
		local outfitId = tostring(action.outfitId)
		return Immutable.RemoveFromDictionary(state, outfitId)
	end

	return state
end

