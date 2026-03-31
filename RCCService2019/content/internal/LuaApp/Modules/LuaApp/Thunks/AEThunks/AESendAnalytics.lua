--[[
	Calls the given analytics function and passes the given values.
	Every analytics function sends the categoryIndex and tabIndex from the store.
	assetTypeId: optional
]]

local function getUserId(state)
	if state.LocalUserId then
		return state.LocalUserId
	end

	if state.RobloxUser and state.RobloxUser.rbxuid then
		return tostring(state.RobloxUser.rbxuid)
	end
end

return function(analyticsFunction, value, assetTypeId)
	return function(store)
		local categoryIndex = store:getState().AEAppReducer.AECategory.AECategoryIndex
		local tabIndex = store:getState().AEAppReducer.AECategory.AETabsInfo[categoryIndex]
		local userId = getUserId(store:getState())
		analyticsFunction(value, categoryIndex, tabIndex, assetTypeId, userId)
	end
end