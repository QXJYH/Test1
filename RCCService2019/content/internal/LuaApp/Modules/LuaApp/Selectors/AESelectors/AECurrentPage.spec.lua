return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AECurrentPage = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPage)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AESelectCategory = require(Modules.LuaApp.Actions.AEActions.AESelectCategory)
	local AESelectCategoryTab = require(Modules.LuaApp.Actions.AEActions.AESelectCategoryTab)
	local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)

	describe("AECurrentPage", function()
		it("should return the first page on initialization.", function()
			local state = AEAppReducer(nil, {})
			local categoryIndex = state.AECategory.AECategoryIndex
			local tabIndex = state.AECategory.AETabsInfo[categoryIndex]
			local currentPage = AECurrentPage(state)
			local actualPage = AECategories.categories[categoryIndex].pages[tabIndex]
			expect(currentPage).to.equal(actualPage)
		end)

		it("should return the correct page.", function()
			local CATEGORY_INDEX = 3
			local TAB_INDEX = 2
			local state = AEAppReducer(nil, AESelectCategory(CATEGORY_INDEX))
			state = AEAppReducer(state, AESelectCategoryTab(CATEGORY_INDEX, TAB_INDEX)) -- Recent All assets page
			local currentPage = AECurrentPage(state)
			local actualPage = AECategories.categories[CATEGORY_INDEX].pages[TAB_INDEX]
			expect(currentPage).to.equal(actualPage)
		end)
	end)
end