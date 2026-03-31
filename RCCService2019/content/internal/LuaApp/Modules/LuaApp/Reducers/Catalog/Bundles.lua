local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local LuaApp = Modules.LuaApp
local Cryo = require(CorePackages.Cryo)
local BundleInfo = require(LuaApp.Models.Catalog.BundleInfo)
local SetBundleInfoAction = require(LuaApp.Actions.Catalog.SetBundleInfoAction)
local SetBundleThumbnailsAction = require(LuaApp.Actions.Catalog.SetBundleThumbnailsAction)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return function(state, action)
    state = state or {}

    if action.type == SetBundleInfoAction.name then
        for key,bundleData in pairs(action.bundles) do
            local bundleId = tostring(key)
            local newBundle = BundleInfo.fromMulitgetBundle(bundleData)
            if not state[bundleId] then
				state = Cryo.Dictionary.join(state, { [bundleId] = newBundle })
            else
                local updatedBundle = BundleInfo.updateBundleWithoutThumbnail(state[bundleId], newBundle)
				state = Cryo.Dictionary.join(state, { [bundleId] = updatedBundle })
			end
        end
        return state
    end

    if action.type == SetBundleThumbnailsAction.name then
		ArgCheck.isType(action.thumbsData, "table", "ThumbsData must be a table of tables.")
		for key,thumbData in pairs(action.thumbsData) do
			local bundleId = tostring(key)
			if not state[bundleId] then
				local newBundle = BundleInfo.fromGetThumbnail(thumbData)
				state = Cryo.Dictionary.join(state, { [bundleId] = newBundle })
            else
                local updatedBundle = BundleInfo.updateThumbnail(state[bundleId], thumbData)
				state = Cryo.Dictionary.join(state, { [bundleId] = updatedBundle })
			end
        end
		return state
    end

    return state
end