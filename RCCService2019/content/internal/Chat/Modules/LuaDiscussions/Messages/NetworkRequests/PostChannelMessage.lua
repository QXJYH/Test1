local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Url = dependencies.Url

local NetworkThunk = require(LuaDiscussions.Url.NetworkThunk)
local MakeNetworkActions = require(LuaDiscussions.Url.MakeNetworkActions)
local UrlBuilder = require(LuaDiscussions.Url.UrlBuilder)

local PostChannelMessage = MakeNetworkActions(script)

function PostChannelMessage.API(networkImpl, channelId, message)
	return NetworkThunk.POST(PostChannelMessage,
		networkImpl,
		UrlBuilder:new(Url.DISCUSSIONS_URL):path("v1/channels"):id(channelId):path("messages"),
		{
			postBody = {
				message = message,
			}
		}
	)
end

return PostChannelMessage