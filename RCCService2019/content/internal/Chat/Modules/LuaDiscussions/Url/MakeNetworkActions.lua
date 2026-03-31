local CorePackages = game:GetService("CorePackages")
local Action = require(CorePackages.AppTempCommon.Common.Action)

local function getFirstId(ids)
	return #ids > 0 and ids[1]
end

return function(networkRequestScript)
	return {
		Succeeded = Action(networkRequestScript.Name .. "_Success", function(ids, responseBody)
			return {
				firstId = getFirstId(ids),
				ids = ids,
				responseBody = responseBody,
			}
		end),
		Failed = Action(networkRequestScript.Name .. "_Failed", function(ids, error)
			return {
				firstId = getFirstId(ids),
				ids = ids,
				error = error,
			}
		end),
	}
end
