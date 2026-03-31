--[[
	Provides a configured networking stack to store in the ServiceProvider
]]--
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local requestInternalWrapper = require(Modules.LuaApp.Http.NetworkLayers.requestInternalWrapper)
local request = requestInternalWrapper()
return request
