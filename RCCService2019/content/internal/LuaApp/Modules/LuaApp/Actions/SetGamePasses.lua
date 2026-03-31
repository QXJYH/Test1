local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(universeId, passes)
	ArgCheck.isType(universeId, "string", "universeId")
	ArgCheck.isType(passes, "table", "passes")

	return {
		universeId = universeId,
		passes = passes,
	}
end)
