local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local LuaAppEvents = require(Modules.LuaApp.LuaAppEvents)
local LuaErrorReporter = require(Modules.Common.LuaErrorReporter)

local MutedErrorReporter = Roact.Component:extend("MutedErrorReporter")

function MutedErrorReporter:init()
	local appName = self.props.appName

	self.errorReporter = LuaErrorReporter.new(LuaAppEvents.ReportMutedError)
	self.errorReporter:setCurrentApp(appName)
	self.errorReporter:startQueueTimers()
end

function MutedErrorReporter:render()
	return nil
end

function MutedErrorReporter:willUnmount()
	self.errorReporter:stopQueueTimers()
end

return MutedErrorReporter
