local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Immutable = require(Modules.Common.Immutable)

local PlayerService = game:GetService("Players")

-- creates an event function with a state table
local function gameDetailsBasicEvent(eventName)
	return function(eventStreamImpl, eventContext, placeId, state)
		assert(type(eventContext) == "string", "Expected eventContext to be a string")
		assert(type(placeId) == "string", "Expected placeId to be a string")
		assert(type(state) == "table", "Expected state to be a table")

		local userId = tostring(PlayerService.LocalPlayer.UserId)

		local eventData = {
			uid = userId,
			placeId = placeId,
		}
		eventData = Immutable.JoinDictionaries(eventData, state)

		eventStreamImpl:setRBXEventStream(eventContext, eventName, eventData)
	end
end

-- creates an event function with a boolean state
local function gameDetailsToggleEvent(eventName)
	local baseEvent = gameDetailsBasicEvent(eventName)
	return function(eventStreamImpl, eventContext, placeId, state)
		assert(type(state) == "boolean", "Expected state to be a boolean")

		return baseEvent(eventStreamImpl, eventContext, placeId, {
			state = state and "on" or "off",
		})
	end
end

-- creates an event function with no state
local function gameDetailsSimpleEvent(eventName)
	local baseEvent = gameDetailsBasicEvent(eventName)
	return function(eventStreamImpl, eventContext, placeId)
		return baseEvent(eventStreamImpl, eventContext, placeId, {})
	end
end

return {
	Favorite = gameDetailsToggleEvent("favorite"),
	Follow = gameDetailsToggleEvent("follow"),
	ShareGameToChat = gameDetailsSimpleEvent("ShareGameToChat"),
	GameDetailsSubpage = function(eventStreamImpl, eventContext, placeId, subpage)
		gameDetailsBasicEvent("gameDetailsSubpage")(eventStreamImpl, eventContext, placeId, {
			subpage = subpage,
		})
	end,
	Vote = function(eventStreamImpl, eventContext, placeId, vote, curVote)
		gameDetailsBasicEvent("vote")(eventStreamImpl, eventContext, placeId, {
			vote = vote,
			prevVote = curVote,
		})
	end,
}
