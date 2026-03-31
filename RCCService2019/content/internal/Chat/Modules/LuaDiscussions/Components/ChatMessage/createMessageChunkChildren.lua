local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local CorePackages = game:GetService("CorePackages")
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local Immutable = require(CorePackages.AppTempCommon.Common.Immutable)

local PlainText = require(Components.ChatMessage.PlainText)

local DEFAULT_PROPS = {
	isIncoming = true,
	maxWidth = 0,
	messageChunks = {},
}

local function buildChunkChild(props, messageChunk)
	-- At some point we will have to do some mapping for these chunk children types

	local isIncoming = props.isIncoming
	local maxWidth = props.maxWidth

	return Roact.createElement(PlainText, {
		innerPadding = 12,
		isIncoming = isIncoming,
		maxWidth = maxWidth,
		messageChunk = messageChunk,
	})
end

local function createMessageChunkChildren(props)
	props = Immutable.JoinDictionaries(DEFAULT_PROPS, props or {})

	local messageChunks = props.messageChunks

	local chunkChildren = {}
	for index, messageChunk in ipairs(messageChunks) do
		chunkChildren[index] = buildChunkChild(props, messageChunk)
	end

	return chunkChildren
end

return createMessageChunkChildren