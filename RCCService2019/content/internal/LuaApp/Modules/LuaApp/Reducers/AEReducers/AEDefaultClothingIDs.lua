local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AESetDefaultClothingIDs = require(Modules.LuaApp.Actions.AEActions.AESetDefaultClothingIDs)

--[[
		These default ids are various colors that sync up with chat username color order.
		Username color list: "Bright red", "Bright blue", "Earth green", "Bright violet",
		"Bright orange", "Bright yellow", "Light reddish violet", "Brick yellow"
]]
return function(state, action)
	state = state or {
		defaultShirtAssetIds = {
			"855776103",
			"855760101",
			"855766176",
			"855777286",
			"855768342",
			"855779323",
			"855773575",
			"855778084"
		},
		defaultPantAssetIds = {
			"855783877",
			"855780360",
			"855781078",
			"855782781",
			"855781508",
			"855785499",
			"855782253",
			"855784936"
		}
	}

	if action.type == AESetDefaultClothingIDs.name then
		local newIds = {
			defaultShirtAssetIds = {},
			defaultPantAssetIds = {},
		}

		for _, id in pairs(action.defaultClothingIDs.defaultShirtAssetIds) do
			newIds.defaultShirtAssetIds[#newIds.defaultShirtAssetIds + 1] = tostring(id)
		end
		for _, id in pairs(action.defaultClothingIDs.defaultPantAssetIds) do
			newIds.defaultPantAssetIds[#newIds.defaultPantAssetIds + 1] = tostring(id)
		end

		return newIds
	end

	return state
end