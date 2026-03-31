local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEActions = Modules.LuaApp.Actions.AEActions

local AEWebApi = require(Modules.LuaApp.Components.Avatar.AEWebApi)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local AEGetOutfit = require(Modules.LuaApp.Thunks.AEThunks.AEGetOutfit)
local AESetOwnedAssets = require(AEActions.AESetOwnedAssets)
local AESetAssetTypeCursor = require(AEActions.AESetAssetTypeCursor)
local AEUserOutfitsStatusAction = require(AEActions.AEWebApiStatus.AEUserOutfitsStatus)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESetInitializedTab = require(Modules.LuaApp.Actions.AEActions.AESetInitializedTab)

local FFlagAvatarEditorUseUserIdFromStore = game:GetFastFlag("AvatarEditorUseUserIdFromStore")

local ASSET_CARDS_PER_PAGE = 25

return function(costumeType, costumesPageNumber)
	return function(store)
		spawn(function()
			local state = store:getState()
			if state.AEAppReducer.AEUserOutfitsStatus[costumeType] == RetrievalStatus.Fetching then
				return
			end

			store:dispatch(AEUserOutfitsStatusAction(RetrievalStatus.Fetching, costumeType))
			costumesPageNumber = state.AEAppReducer.AEAssetTypeCursor[costumeType] or 1

			local isEditable = costumeType == AEConstants.OUTFITS and true or false
			local userId = FFlagAvatarEditorUseUserIdFromStore and
				store:getState().LocalUserId or game.Players.LocalPlayer.userId
			local outfitsWebCall, status = AEWebApi.GetUserCostumes(userId,
				costumesPageNumber, ASSET_CARDS_PER_PAGE, isEditable)

			if outfitsWebCall then
				local data = outfitsWebCall["data"]
				if data then
					local costumeIds = {}
					for _, costume in pairs(data) do
						costumeIds[#costumeIds + 1] = tostring(costume.id)

						-- Get this costume's data before showing it to prevent async problems.
						store:dispatch(AEGetOutfit(costume.id))
					end

					if #costumeIds == 0 then
						store:dispatch(AESetAssetTypeCursor(costumeType, AEConstants.REACHED_LAST_PAGE))
					elseif costumesPageNumber ~= AEConstants.REACHED_LAST_PAGE then
						store:dispatch(AESetAssetTypeCursor(costumeType, costumesPageNumber + 1))
					end

					store:dispatch(AESetOwnedAssets(costumeType, costumeIds))
					store:dispatch(AESetInitializedTab(costumeType))
				end
			end

			if status ~= AEWebApi.Status.OK then
				warn("AEWebApi failure in GetUserOutfits")
				store:dispatch(AEUserOutfitsStatusAction(RetrievalStatus.Failed, costumeType))
				return
			end
			store:dispatch(AEUserOutfitsStatusAction(RetrievalStatus.Done, costumeType))
		end)
	end
end