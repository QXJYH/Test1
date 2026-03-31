local HttpCanceller = {}

local sessionId = 0

function HttpCanceller.currentSession()
	return sessionId
end

function HttpCanceller.cancel()
	sessionId = sessionId + 1
end

return HttpCanceller