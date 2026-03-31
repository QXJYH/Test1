local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Model = dependencies.Model

local ChannelMessage = Model.extend("ChannelMessage")

return Model.requiredProps(ChannelMessage, {
	created = "string",
	chunks = "table",
	id = "string",
})