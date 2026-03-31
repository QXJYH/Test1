--[[
	A component periodically send an Heartbeat status to the server when the user's presence is located
]]
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)

local ArgCheck = require(Modules.LuaApp.ArgCheck)
local AppPresenceLocationId = require(Modules.LuaApp.AppPresenceLocationId)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local RoactServices = require(Modules.LuaApp.RoactServices)

local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local PostRegisterAppPresence = require(Modules.LuaApp.Thunks.PostRegisterAppPresence)

local PRESENCE_POLL_INTERVAL = FlagSettings.LuaAppPresencePollingIntervalInSeconds()

local AppPresence = Roact.PureComponent:extend("AppPresence")

function AppPresence:init()
	self._presenceTimer = tick() + PRESENCE_POLL_INTERVAL
	self._anyInputReceived = false

	self.inputBeganCallback = function()
		if self._anyInputReceived == false then
			self._anyInputReceived = true
		end
	end

	self.renderSteppedCallback = function(dt)
		local currentTick = tick()
		if currentTick > self._presenceTimer and PRESENCE_POLL_INTERVAL > 0 then
			self._presenceTimer = currentTick + PRESENCE_POLL_INTERVAL

			-- AppShell shouldn't be paused longer than PRESENCE_POLL_INTERVAL
			if dt < PRESENCE_POLL_INTERVAL and self._anyInputReceived then
				local locationId = self.props.locationId
				ArgCheck.isNonEmptyString(locationId, "AppPresence.locationId")
				self.props.registerAppPresence(self.props.networking, locationId)
			end
			self._anyInputReceived = false
		end
	end
end

function AppPresence:render()
	if RunService:IsStudio() then
		return nil
	end

	return Roact.createElement("Folder", {}, {
		inputBeganListener = Roact.createElement(ExternalEventConnection, {
			event = UserInputService.InputBegan,
			callback = self.inputBeganCallback,
		}),
		renderSteppedListener = Roact.createElement(ExternalEventConnection, {
			event = RunService.renderStepped,
			callback = self.renderSteppedCallback,
		}),
	})
end

AppPresence = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		local pageName = currentRoute[#currentRoute].name
		return {
			locationId = AppPresenceLocationId[pageName],
		}
	end,
	function(dispatch)
		return {
			registerAppPresence = function(networking, locationId)
				return dispatch(PostRegisterAppPresence(networking, locationId))
			end,
		}
	end
)(AppPresence)

return RoactServices.connect({
	networking = RoactNetworking,
})(AppPresence)