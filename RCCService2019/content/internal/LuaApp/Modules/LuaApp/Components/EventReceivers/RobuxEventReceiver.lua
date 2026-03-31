local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ApiFetchEconomyCurrency = require(Modules.LuaApp.Thunks.ApiFetchEconomyCurrency)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local REQUEST_ROBUX_TIME_DELAY = 3

local RobuxEventReceiver = Roact.Component:extend("RobuxEventReceiver")

function RobuxEventReceiver:init()
	self.isMounted = false

	local robloxEventReceiver = self.props.RobloxEventReceiver

	self.updateRobux = function()
		local localUserId = self.props.localUserId
		local requestRobuxInfo = self.props.requestRobuxInfo
		local networking = self.props.networking

		ArgCheck.isNonEmptyString(localUserId, "RobuxEventReceiver.updateRobux.localUserId")
		if typeof(localUserId) == "string" and localUserId ~= "" then
			requestRobuxInfo(networking, localUserId)
		end
	end

	self.tokens = {
		-- TODO: this is a workaround until:
		-- 1. the `PurchaseFinished` event exists
		-- 2. We can persist Robux info across datamodels and update
		-- the Robux in the app when a purchase happens in the game
		robloxEventReceiver:observeEvent("AppInput", function(detail, detailType)
			if detailType == "Focused" then
				delay(REQUEST_ROBUX_TIME_DELAY, function()
					if not self.isMounted then
						return
					end
					self.updateRobux()
				end)
			end
		end)
	}
end

function RobuxEventReceiver:render()
	return Roact.oneChild(self.props[Roact.Children])
end

function RobuxEventReceiver:didMount()
	self.isMounted = true
end

function RobuxEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:Disconnect()
	end
	self.isMounted = false
end

RobuxEventReceiver = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			localUserId = state.LocalUserId,
		}
	end,
	function(dispatch)
		return {
			requestRobuxInfo = function(networking, userId)
				return dispatch(ApiFetchEconomyCurrency(networking, userId, true))
			end,
		}
	end
)(RobuxEventReceiver)

return RoactServices.connect({
	networking = RoactNetworking,
})(RobuxEventReceiver)