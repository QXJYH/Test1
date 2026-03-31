return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AECurrentPageHasAssets = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPageHasAssets)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AESelectCategory = require(Modules.LuaApp.Actions.AEActions.AESelectCategory)
	local AESelectCategoryTab = require(Modules.LuaApp.Actions.AEActions.AESelectCategoryTab)
	local AEAddRecentAsset = require(Modules.LuaApp.Actions.AEActions.AEAddRecentAsset)
	local AEToggleEquipAsset = require(Modules.LuaApp.Actions.AEActions.AEToggleEquipAsset)
	local AESetOwnedAssets = require(Modules.LuaApp.Actions.AEActions.AESetOwnedAssets)

	local mockFilledState = AEAppReducer(nil, {})

	mockFilledState = AEAppReducer(mockFilledState, AEAddRecentAsset({{ assetTypeId = "8", assetId = "1" }}, false))
	mockFilledState = AEAppReducer(mockFilledState, AEToggleEquipAsset("41", "333"))
	mockFilledState = AEAppReducer(mockFilledState, AESetOwnedAssets("8", { "1", "2", "3" }))

	describe("AECurrentPageHasAssets", function()
		it("should return false when there are no recent assets on the recent page.", function()
			local state = AEAppReducer(nil, AESelectCategory(1))
			state = AEAppReducer(state, AESelectCategoryTab(1, 2)) -- Recent All assets page
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(false)
		end)

		it("should return false when there are no equipped assets on the currently wearing page.", function()
			local state = AEAppReducer(nil, AESelectCategory(1))
			state = AEAppReducer(state, AESelectCategoryTab(1, 1)) -- Currently Wearing page
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(false)
		end)

		it("should return false when there are no owned assets for a page.", function()
			local state = AEAppReducer(nil, AESelectCategory(1))
			state = AEAppReducer(state, AESelectCategoryTab(2, 1)) -- Hats asset page
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(false)
		end)


		it("should return true when there are recent assets on the recent page.", function()
			local state = AEAppReducer(mockFilledState, AESelectCategoryTab(1, 2)) -- Recent All assets page.
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(true)
		end)

		it("should return true when there are equipped assets on the currently wearing page.", function()
			local state = AEAppReducer(mockFilledState, AESelectCategoryTab(1, 1)) -- Currently wearing page
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(true)
		end)

		it("should return true when there are owned assets for a page.", function()
			local state = AEAppReducer(mockFilledState, AESelectCategoryTab(2, 1)) -- Hats page
			local currentPageHasAssets = AECurrentPageHasAssets(state)
			expect(currentPageHasAssets).to.equal(true)
		end)
	end)
end