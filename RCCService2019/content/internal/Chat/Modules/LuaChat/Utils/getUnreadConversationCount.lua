local CoreGui = game:GetService("CoreGui")
local memoize = require(CoreGui.RobloxGui.Modules.Common.memoize)

return memoize(function(conversationState)
	local sum = 0
	for _, conversation in pairs(conversationState) do
		if conversation.hasUnreadMessages then
			sum = sum + 1
		end
	end
	return sum
end)