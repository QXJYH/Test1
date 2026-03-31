local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(left, top, right, bottom)
	ArgCheck.isNonNegativeNumber(left, "SetGlobalGuiInset: left")
	ArgCheck.isNonNegativeNumber(top, "SetGlobalGuiInset: top")
	ArgCheck.isNonNegativeNumber(right, "SetGlobalGuiInset: right")
	ArgCheck.isNonNegativeNumber(bottom, "SetGlobalGuiInset: bottom")

	return {
		left = left,
		top = top,
		right = right,
		bottom = bottom,
	}
end)