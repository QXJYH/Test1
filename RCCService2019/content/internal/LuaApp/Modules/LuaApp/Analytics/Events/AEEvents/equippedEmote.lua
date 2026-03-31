-- equippedEmote : sent when the user equips an emote in the Lua avatar editor.
-- userId : (string) the UserId of the logged in user.
-- browserTrackerId : (string) the BrowserTrackerId for the logged in user.
-- assetId : (string) the assetId of the equipped emote.
-- slot : (number) the slot for the equipped emote.

return function(eventStreamImpl, userId, browserTrackerId, assetId, slot)
	assert(type(userId) == "string", "Expected userId to be a string")
    assert(type(browserTrackerId) == "string", "Expected browserTrackerId to be a string")
    assert(type(assetId) == "string", "Expected assetId to be a string")
    assert(type(slot) == "number", "Expected slot to be a number")

    local eventName = "equippedEmote"
    local eventContext = "avatarEditor"

	eventStreamImpl:setRBXEventStream(eventContext, eventName, {
            uid = userId,
            btid = browserTrackerId,
            slot = slot,
            assetID = assetId,
		}
	)
end