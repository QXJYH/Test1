return function()
	SKIP()
	local EventStreamUpdater = require(script.Parent.EventStreamUpdater)
	local CorePackages = game:GetService("CorePackages")
	local CoreGui = game:GetService("CoreGui")
	local Modules = CoreGui.RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			EventStreamUpdater = Roact.createElement(EventStreamUpdater, {
				releasePeriod = 1000,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
