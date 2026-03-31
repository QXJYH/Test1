local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local Modules = CoreGui.RobloxGui.Modules

local avatarEditorPropertyChanged = require(Modules.LuaApp.Analytics.Events.AEEvents.avatarEditorPropertyChanged)
local equippedEmote = require(Modules.LuaApp.Analytics.Events.AEEvents.equippedEmote)
local openedEmotesPage = require(Modules.LuaApp.Analytics.Events.AEEvents.openedEmotesPage)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local FFlagAvatarEditorEmotesAnalytics3 = settings():GetFFlag("AvatarEditorEmotesAnalytics3")

local AvatarEditorAnalytics = {}

function AvatarEditorAnalytics.get(context)
	local analyticsImpl = RoactAnalytics.get(context)

	local AEA = {}

	local sendEvent = function(eventContext, propertyValue, categoryIndex, tabIndex, propertyName)
		avatarEditorPropertyChanged(analyticsImpl.EventStream, eventContext,
			propertyName, propertyValue, categoryIndex, tabIndex)
	end

	function AEA.equipAsset(assetId, categoryIndex, tabIndex, assetTypeId, userId)
		local assetName = tostring(AEConstants.AssetTypeNames[assetTypeId])

		if FFlagAvatarEditorEmotesAnalytics3 then
			if AEConstants.AssetTypes.Emote == assetTypeId then
				local browserTrackerId = Stats:GetBrowserTrackerId()
				equippedEmote(analyticsImpl.EventStream, userId, browserTrackerId, assetId, tabIndex)
			end
		end

		sendEvent("EquipAsset", assetId, categoryIndex, tabIndex, assetName or "UnknownAssetTypeId: " ..assetTypeId)
	end

	function AEA.unequipAsset(assetId, categoryIndex, tabIndex, assetTypeId)
		local assetName = tostring(AEConstants.AssetTypeNames[assetTypeId])

		sendEvent("UnequipAsset", assetId, categoryIndex, tabIndex, assetName or "UnknownAssetTypeId: " ..assetTypeId)
	end

	function AEA.setAvatarHeadSize(headSize, categoryIndex, tabIndex)
		sendEvent("SetHeadSize", headSize, categoryIndex, tabIndex, "HeadSize")
	end

	function AEA.setAvatarHeight(height, categoryIndex, tabIndex)
		sendEvent("SetHeight", height, categoryIndex, tabIndex, "Height")
	end

	function AEA.setAvatarWidth(width, categoryIndex, tabIndex)
		sendEvent("SetWidth", width, categoryIndex, tabIndex, "Width")
	end

	function AEA.setAvatarBodyType(bodyType, categoryIndex, tabIndex)
		sendEvent("SetBodyType", bodyType, categoryIndex, tabIndex, "BodyType")
	end

	function AEA.setAvatarProportion(proportion, categoryIndex, tabIndex)
		sendEvent("SetProportion", proportion, categoryIndex, tabIndex, "Proportion")
	end

	function AEA.toggleAvatarType(avatarType, categoryIndex, tabIndex)
		sendEvent("SetAvatarType", avatarType, categoryIndex, tabIndex, "AvatarType")
	end

	function AEA.setBodyColors(bodyColors, categoryIndex, tabIndex)
		local commonColor = bodyColors[next(bodyColors)] or "empty"

		for _,color in pairs(bodyColors) do
			commonColor = (color == commonColor) and commonColor or "mixed"
		end

		sendEvent("SetBodyColors", commonColor, categoryIndex, tabIndex, "BodyColors")
	end

	function AEA.openedEmotesPage(userId)
		local browserTrackerId = Stats:GetBrowserTrackerId()

		openedEmotesPage(analyticsImpl.EventStream, userId, browserTrackerId)
	end

	return AEA
end

return AvatarEditorAnalytics
