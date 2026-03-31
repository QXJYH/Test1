local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Rodux = require(CorePackages.Rodux)
local TableUtilities = require(CorePackages.AppTempCommon.LuaApp.TableUtilities)
local SetScreenGuiBlur = require(Modules.LuaApp.Actions.SetScreenGuiBlur)

return Rodux.createReducer({
	hasBlur = false,
	blurDisplayOrder = 0,
	details = {},
}, {
	[SetScreenGuiBlur.name] = function(state, action)
		local details
		if action.blur == true then
			details = Cryo.Dictionary.join(state.details, {
				[action.source] = action.displayOrder,
			})
		else
			details = Cryo.Dictionary.join(state.details, {
				[action.source] = Cryo.None,
			})
		end

		local hasBlur = (TableUtilities.FieldCount(details) > 0)
		local blurDisplayOrder = 0
		for _, displayOrder in pairs(details) do
			blurDisplayOrder = math.max(blurDisplayOrder, displayOrder)
		end

		return {
			hasBlur = hasBlur,
			blurDisplayOrder = blurDisplayOrder,
			details = details,
		}
	end,
})