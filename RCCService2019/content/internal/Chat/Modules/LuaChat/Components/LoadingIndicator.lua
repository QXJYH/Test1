local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat

local Create = require(LuaChat.Create)
local LoadingBar = require(LuaApp.Components.LoadingBar)
local Roact = require(Common.Roact)

local LOADING_INDICATOR_WIDTH = 70
local LOADING_INDICATOR_HEIGHT = 16

local LoadingIndicator = {}

function LoadingIndicator.new(appState, scale)
	scale = scale or 1

	local self = {}
	self.connections = {}

	self.rbx = Create.new "Frame" {
		Name = "LoadingIndicator",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, scale * LOADING_INDICATOR_WIDTH, 0, scale * LOADING_INDICATOR_HEIGHT)
	}

	self.loadingBar = Roact.mount(Roact.createElement(LoadingBar), self.rbx)

	setmetatable(self, LoadingIndicator)

	do
		local connection = self.rbx.AncestryChanged:Connect(function(object, parent)
			if object == self.rbx and parent == nil then
				self:Destroy()
			end
		end)
		table.insert(self.connections, connection)
	end

	return self
end

function LoadingIndicator:SetZIndex(index)
	self.rbx.ZIndex = index
	if self.loadingBar then
		self.loadingBar.ZIndex = index
	end
end

function LoadingIndicator:SetVisible(visible)
	self.rbx.Visible = visible
end

function LoadingIndicator:Destroy()
	if self.loadingBar then
		Roact.unmount(self.loadingBar)
		self.loadingBar = nil
	end

	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	self.rbx:Destroy()
	self.connections = {}
end

LoadingIndicator.__index = LoadingIndicator

return LoadingIndicator