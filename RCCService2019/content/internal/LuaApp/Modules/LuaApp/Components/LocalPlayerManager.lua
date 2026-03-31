local CorePackages = game:GetService("CorePackages")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local SetUserMembershipType = require(Modules.LuaApp.Actions.SetUserMembershipType)
local GetLocalUser = require(Modules.LuaApp.Thunks.GetLocalUser)

local LocalPlayerManager = Roact.Component:extend("LocalPlayerManager")

function LocalPlayerManager:init()
	self.state = {
		hasLocalPlayer = Players.LocalPlayer ~= nil
	}
end

function LocalPlayerManager:render()
	local setUserMembershipType = self.props.setUserMembershipType

	local children = {
		Roact.createElement(ExternalEventConnection, {
			event = Players.PlayerRemoving,
			callback = function()
				self:setState({ hasLocalPlayer = Players.LocalPlayer ~= nil })
			end,
		}),
		Roact.createElement(ExternalEventConnection, {
			event = Players.PlayerAdded,
			callback = function()
				self:setState({ hasLocalPlayer = Players.LocalPlayer ~= nil })
			end,
		}),
	}
	if self.state.hasLocalPlayer then
		table.insert(children, Roact.createElement(ExternalEventConnection, {
			event = Players.LocalPlayer:GetPropertyChangedSignal("MembershipType"),
			callback = function()
				local localPlayer = Players.LocalPlayer
				local userId = tostring(localPlayer.UserId)
				setUserMembershipType(userId, localPlayer.MembershipType)
			end,
		}))
		table.insert(children, Roact.createElement(ExternalEventConnection, {
				event = Players.LocalPlayer:GetPropertyChangedSignal("UserId"),
				callback = self.props.fetchLocalUserData,
		}))
	end
	return Roact.createElement("Folder", {}, children)
end

function LocalPlayerManager:didMount()
	if (self.state.hasLocalPlayer) then
		self.props.fetchLocalUserData()
	end
end

return RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			setUserMembershipType = function(userId, membershipType)
				dispatch(SetUserMembershipType(userId, membershipType))
			end,
			fetchLocalUserData = function()
				dispatch(GetLocalUser())
			end,
		}
	end
)(LocalPlayerManager)
