-- nsOpenContent : fired when the Notification Stream button is tapped.
-- eventContext: (string) The current page that is opened or context
-- countOfUnreadNotifications: (string) count of unread messages in the notification stream
return function(eventStreamImpl, eventContext, countOfUnreadNotifications)
	assert(type(eventContext) == "string", "Expected eventContext to be a string")
	assert(type(countOfUnreadNotifications) == "number", "Expected countOfUnreadNotifications to be a number")

	local eventName = "nsOpenContent"
	eventStreamImpl:setRBXEventStream(eventContext, eventName, {
		property = countOfUnreadNotifications,
	})
end