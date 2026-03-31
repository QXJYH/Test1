local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(universeId, badges)
	ArgCheck.isType(universeId, "string", "universeId")
	ArgCheck.isType(badges, "table", "badges")

	return {
		universeId = universeId,
		badges = badges,
	}
end)
