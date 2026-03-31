-- openedEmotesPage : sent when the Emotes category page in the avatar editor is opened.
-- userId : (string) the UserId of the logged in user.
-- browserTrackerId : (string) the BrowserTrackerId for the logged in user.

return function(eventStreamImpl, userId, browserTrackerId)
	assert(type(userId) == "string", "Expected userId to be a string")
	assert(type(browserTrackerId) == "string", "Expected browserTrackerId to be a string")

    local eventName = "openedEmotesPage"
    local eventContext = "avatarEditor"

	eventStreamImpl:setRBXEventStream(eventContext, eventName, {
            uid = userId,
			btid = browserTrackerId,
		}
	)
end