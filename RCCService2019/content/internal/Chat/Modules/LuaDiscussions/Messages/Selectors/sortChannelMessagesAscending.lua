local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Cryo = dependencies.Cryo

local function sortChannelMessages(channelMessages)
	local channelMessagesArray = Cryo.Dictionary.values(channelMessages)

	table.sort(channelMessagesArray, function(a, b)
		return a.created < b.created
	end)

	return channelMessagesArray
end

return sortChannelMessages