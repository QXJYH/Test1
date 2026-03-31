local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Url = dependencies.Url

local NetworkThunk = require(LuaDiscussions.Url.NetworkThunk)
local MakeNetworkActions = require(LuaDiscussions.Url.MakeNetworkActions)
local UrlBuilder = require(LuaDiscussions.Url.UrlBuilder)

local GetChannelMessages = MakeNetworkActions(script)

function GetChannelMessages.API(networkImpl, channelId)
	return NetworkThunk.GET(GetChannelMessages,
		networkImpl,
		UrlBuilder:new(Url.DISCUSSIONS_URL):path("v1/channels"):id(channelId):path("messages")
	)
end

return GetChannelMessages