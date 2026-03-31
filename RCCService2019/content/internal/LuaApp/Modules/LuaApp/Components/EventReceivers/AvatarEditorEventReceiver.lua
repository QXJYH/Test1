local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AEGrantAsset = require(Modules.LuaApp.Thunks.AEThunks.AEGrantAsset)
local AERevokeAsset = require(Modules.LuaApp.Thunks.AEThunks.AERevokeAsset)
local AESetConnectionState  = require(Modules.LuaApp.Actions.AEActions.AESetConnectionState)

local AEGrantOutfit = require(Modules.LuaApp.Thunks.AEThunks.AEGrantOutfit)
local AERevokeOutfit = require(Modules.LuaApp.Thunks.AEThunks.AERevokeOutfit)
local AEUpdateOutfit = require(Modules.LuaApp.Thunks.AEThunks.AEUpdateOutfit)

local AvatarEditorEventReceiver = Roact.Component:extend("AvatarEditorEventReceiver")

local GRANT = "Grant"
local REVOKE = "Revoke"
local UPDATE = "Update"

function AvatarEditorEventReceiver:init()
	local robloxEventReceiver = self.props.RobloxEventReceiver
	local grantAsset = self.props.grantAsset
	local revokeAsset = self.props.revokeAsset
	local grantOutfit = self.props.grantOutfit
	local revokeOutfit = self.props.revokeOutfit
	local updateOutfit = self.props.updateOutfit
	local setConnectionState = self.props.setConnectionState

	self.tokens = {
		robloxEventReceiver:observeEvent("AvatarAssetOwnershipNotifications", function(detail)
			if detail.Type == GRANT then
				grantAsset(detail.AssetTypeId, detail.AssetId)
			elseif detail.Type == REVOKE then
				revokeAsset(detail.AssetTypeId, detail.AssetId)
			end
		end),
		robloxEventReceiver:observeEvent("signalR", function(connectionState)
			setConnectionState(connectionState)
		end),
		robloxEventReceiver:observeEvent("AvatarOutfitOwnershipNotifications", function(detail)
			if detail.Type == GRANT then
				grantOutfit(detail.UserOutfitId)
			elseif detail.Type == REVOKE then
				revokeOutfit(detail.UserOutfitId)
			elseif detail.Type == UPDATE then
				updateOutfit(detail.UserOutfitId)
			end
		end),
	}
end

function AvatarEditorEventReceiver:render()
end

function AvatarEditorEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:Disconnect()
	end
end

return RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			grantAsset = function(assetTypeId, assetId)
				return dispatch(AEGrantAsset(assetTypeId, assetId))
			end,
			revokeAsset = function(assetTypeId, assetId)
				return dispatch(AERevokeAsset(assetTypeId, assetId))
			end,
			setConnectionState = function(connectionState)
				return dispatch(AESetConnectionState(connectionState))
			end,
			grantOutfit = function(outfitId)
				return dispatch(AEGrantOutfit(outfitId))
			end,
			revokeOutfit = function(outfitId)
				return dispatch(AERevokeOutfit(outfitId))
			end,
			updateOutfit = function(outfitId)
				return dispatch(AEUpdateOutfit(outfitId))
			end,
		}
	end
)(AvatarEditorEventReceiver)