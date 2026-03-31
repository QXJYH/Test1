local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Modules = CoreGui.RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)

local AntiAddictionPrompt = require(Modules.LuaApp.Components.AntiAddictionPrompt)
local AntiAddictionMarkRead = require(Modules.LuaApp.Thunks.AntiAddictionMarkRead)
local LogoutThunk = require(Modules.LuaApp.Thunks.Authentication.Logout)

local AntiAddictionEventReceiver = Roact.Component:extend("AntiAddictionEventReceiver")

local AntiAddictionStates = {
	Normal = 1,
	LockedOut = 2,
}

function AntiAddictionEventReceiver:init()
	local robloxEventReceiver = self.props.RobloxEventReceiver

	self.state = {
		type = AntiAddictionStates.Normal,
		promptsCount = 0,
		promptsIndex = 0,
		prompts = {},
	}

	self.setAntiAddictionPrompts = function(responseTable)
		local antiAddictionPrompts = {}
		local type = responseTable.response.state.type
		local messages = responseTable.response.state.messages
		for _, message in ipairs(messages) do
			local id = message.id
			local text = message.text
			local prompt = {
				id = id,
				text = text,
			}
			table.insert(antiAddictionPrompts, prompt)
		end
		local promptsIndex = 1
		local promptsCount = #antiAddictionPrompts
		self:setState({
			type = type,
			promptsIndex = promptsIndex,
			promptsCount = promptsCount,
			prompts = antiAddictionPrompts,
		})
	end

	self.tokens = {
		robloxEventReceiver:observeEvent("AntiAddictionNotifications", function(detail, detailType)
			if detailType == "InvalidAuthToken" then
				self.props.doLogout(self.props.networking, self.props.guiService)
			else
				self.setAntiAddictionPrompts(detail)
			end
		end)
	}

	self.ok = function()
		local promptsIndex = self.state.promptsIndex + 1
		local promptsCount = self.state.promptsCount
		if promptsIndex > promptsCount then
			-- All messenges have been shown. Close all prompts.
			self:setState({
				promptsIndex = 0,
				promptsCount = 0,
			})
		else
			self:setState({
				promptsIndex = promptsIndex,
			})
		end
	end
end

function AntiAddictionEventReceiver:render()
	local alert
	if self.state.promptsCount > 0 then
		local type = self.state.type
		local index = self.state.promptsIndex
		local prompt = self.state.prompts[index]
		local id = prompt.id or ""
		local text = prompt.text
		alert = Roact.createElement(Roact.Portal, {
				target = CoreGui,
			},{
				["prompt:"..id] = Roact.createElement(AntiAddictionPrompt, {
					okCallback = self.ok,
					message = text,
					lockOut = type == AntiAddictionStates.LockedOut,
				})
			})
		self.props.markRead(self.props.networking, id)
	end
	return alert
end

function AntiAddictionEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:disconnect()
	end
end

AntiAddictionEventReceiver = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			markRead = function(networking, messageId)
				return dispatch(AntiAddictionMarkRead(networking, messageId))
			end,
			doLogout = function(networking, guiService)
				dispatch(LogoutThunk(networking, guiService))
			end,
		}
	end
)(AntiAddictionEventReceiver)

return RoactServices.connect({
	networking = RoactNetworking,
	guiService = AppGuiService,
})(AntiAddictionEventReceiver)