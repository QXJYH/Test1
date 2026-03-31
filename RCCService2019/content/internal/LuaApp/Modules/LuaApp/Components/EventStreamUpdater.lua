local CorePackages = game:GetService("CorePackages")
local RunService = game:GetService("RunService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)


local EventStreamUpdateComponent = Roact.Component:extend("EventStreamUpdateComponent")

function EventStreamUpdateComponent:render()
	return nil
end

function EventStreamUpdateComponent:didMount()
	local analytics = self.props.analytics
	local releasePeriod = self.props.releasePeriod

	local function releaseStream()
		-- there is currently a bug with the EventStream, where the stream is not released
		-- by the game engine. This call is a temporary work around until a new api is available.
		analytics.EventStream:releaseRBXEventStream()
	end

	-- Make sure that analytics are reported
	self.releaseEvents = true
	spawn(function()
		wait(releasePeriod)
		while self.releaseEvents do
			releaseStream()
			wait(releasePeriod)
		end
	end)

	-- the BindToClose function does not play nicely with Studio.
	if not RunService:IsStudio() then
		game:BindToClose(function()
			self.releaseEvents = false
			releaseStream()
		end)
	end
end

return RoactServices.connect({
	analytics = RoactAnalytics,
})(EventStreamUpdateComponent)
