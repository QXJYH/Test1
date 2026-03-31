local MockRunService = {}
MockRunService.__index = MockRunService

function MockRunService.new()
	local self = {}
	setmetatable(self, {
		__index = MockRunService,
	})
	return self
end

function MockRunService:GetRobloxVersion()
	return "0.0.0.1"
end

MockRunService.Heartbeat = {
	Wait = function() end
}

return MockRunService
