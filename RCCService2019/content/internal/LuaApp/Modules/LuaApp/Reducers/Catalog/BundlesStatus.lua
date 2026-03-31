local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Rodux = require(CorePackages.Rodux)
local SetBundleStatus = require(Modules.LuaApp.Actions.Catalog.SetBundleStatus)
local Cryo = require(CorePackages.Cryo)

return Rodux.createReducer({}, {
	--[[
		action.id: string
		action.purchaseStatus: number
	]]
	[SetBundleStatus.name] = function(state, action)
		local id = action.id
		local purchaseStatus = action.purchaseStatus
		return Cryo.Dictionary.join(state, { [id] = purchaseStatus })
	end,
})
