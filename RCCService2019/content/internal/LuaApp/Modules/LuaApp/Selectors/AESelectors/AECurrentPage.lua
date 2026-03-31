local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)

--[[
	Gets the current page the Avatar Editor is on.
	Expects state to be AEAppReducer.
]]
return function(state)
	local categoryIndex = state.AECategory.AECategoryIndex
	local tabsInfo = state.AECategory.AETabsInfo
	local tabIndex = tabsInfo[categoryIndex]
	local categoryPages = AECategories.categories[categoryIndex].pages

	return categoryPages[tabIndex]
end