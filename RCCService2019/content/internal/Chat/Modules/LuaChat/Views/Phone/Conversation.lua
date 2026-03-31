local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp

local BaseScreen = require(script.Parent.BaseScreen)

local Components = LuaChat.Components
local ConversationComponent = require(Components.Conversation)

local DialogInfo = require(LuaChat.DialogInfo)

local PopRoute = require(LuaChat.Actions.PopRoute)
local SetRoute = require(LuaChat.Actions.SetRoute)

local FormFactor = require(LuaApp.Enum.FormFactor)

local Intent = DialogInfo.Intent

local FFlagLuaChatSwipeToGoBackFromConversation = settings():GetFFlag("LuaChatSwipeToGoBackFromConversation369")

local ConversationView = BaseScreen:Template()

ConversationView.__index = ConversationView
ConversationView.viewCache = {}

function ConversationView:Get(appState, route)
	if self.viewCache[route.parameters.conversationId] then
		return self.viewCache[route.parameters.conversationId]
	end

	local view = self.new(appState, route)
	self.viewCache[route.parameters.conversationId] = view

	return view
end

function ConversationView.new(appState, route)
	local self = {}
	self.route = route
	self.conversationId = route.parameters.conversationId
	self.appState = appState
	self.connections = {}
	self.robloxConnections = {}

	setmetatable(self, ConversationView)

	self.conversationComponent = ConversationComponent.new(appState)
	self.rbx = self.conversationComponent.rbx

	return self
end

function ConversationView:Start()
	BaseScreen.Start(self)

	if FFlagLuaChatSwipeToGoBackFromConversation then
		local state = self.appState.store:getState()

		if state.FormFactor == FormFactor.COMPACT then
			local swipeConnection = self.rbx.TouchSwipe:Connect(function(direction, touchCount)
				if direction == Enum.SwipeDirection.Right and touchCount == 1 then
					self.appState.store:dispatch(PopRoute())
				end
			end)
			table.insert(self.robloxConnections, swipeConnection)
		end
	end

	local backButtonConnection = self.conversationComponent.BackButtonPressed:connect(function()
		self.appState.store:dispatch(PopRoute())
	end)
	table.insert(self.connections, backButtonConnection)

	local groupDetailConnection = self.conversationComponent.GroupDetailsButtonPressed:connect(function()
		self.appState.store:dispatch(SetRoute(
			Intent.GroupDetail,
			{
				conversationId = self.conversationId,
			}
		))
	end)
	table.insert(self.connections, groupDetailConnection)

	do
		local connection = self.appState.store.changed:connect(function(state, oldState)
			local conversation = state.ChatAppReducer.Conversations[self.conversationId]

			if not conversation then
				if self.appState.screenManager:GetCurrentView() == self then
					self.appState.store:dispatch(SetRoute(
						nil,
						{},
						Intent.ConversationHub
					))
				end
				self:Stop()
				self.viewCache[self.conversationId] = nil
				return
			end
			self.conversationComponent:Update(state, oldState)
		end)
		table.insert(self.connections, connection)
	end

	self.conversationComponent:Start()
end

function ConversationView:Stop()
	BaseScreen.Stop(self)
	self.conversationComponent:Stop()

	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end

	for _, connection in ipairs(self.robloxConnections) do
		connection:Disconnect()
	end

	self.connections = {}
	self.robloxConnections = {}
end

function ConversationView:Pause()
	BaseScreen.Pause(self)
	self.conversationComponent:Pause()
end

function ConversationView:Resume()
	BaseScreen.Resume(self)
	self.conversationComponent:Resume()
end



return ConversationView
