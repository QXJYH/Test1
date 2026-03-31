local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(id, purchaseStatus)
	return {
		id = id,
		purchaseStatus = purchaseStatus,
	}
end)
