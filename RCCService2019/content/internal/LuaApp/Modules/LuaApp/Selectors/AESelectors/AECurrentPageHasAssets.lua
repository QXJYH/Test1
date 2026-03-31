local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local FFlagAvatarEditorRefactorPageType = settings():GetFFlag("AvatarEditorRefactorPageType")

--[[
	Calculates if there are assets to render and caches the result.
	Expects state to be AEAppReducer.
]]
return function(state)
	local categoryIndex = state.AECategory.AECategoryIndex
	local tabsInfo = state.AECategory.AETabsInfo
	local page = AEUtils.getCurrentPage(categoryIndex, tabsInfo)
	local isRecentPage = (FFlagAvatarEditorRefactorPageType and page.pageType == AEConstants.PageType.RecentAll)
		or (not FFlagAvatarEditorRefactorPageType and page.recentPageType)

	if isRecentPage then
		return #state.AECharacter.AERecentAssets > 0
	elseif page.assetTypeId then
		return state.AECharacter.AEOwnedAssets[page.assetTypeId]
		and #state.AECharacter.AEOwnedAssets[page.assetTypeId] > 0
	elseif page.pageType == AEConstants.PageType.CurrentlyWearing then
		return state.AECharacter.AEEquippedAssets and
			#AEUtils.getEquippedAssetIds(state.AECharacter.AEEquippedAssets) > 0 or false
	end

	return false
end