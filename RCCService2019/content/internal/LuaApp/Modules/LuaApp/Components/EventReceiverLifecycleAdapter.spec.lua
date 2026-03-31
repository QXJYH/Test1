return function()
	local EventReceiverLifecycleAdapter = require(script.Parent.EventReceiverLifecycleAdapter)
	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local NotificationService = game:GetService("NotificationService")
	local Roact = require(CorePackages.Roact)
	local RobloxEventReceiver = require(Modules.LuaApp.RobloxEventReceiver)

	it("should create and destroy without errors", function()
		local rbxEventReceiver = RobloxEventReceiver.new(NotificationService)
		local element = Roact.createElement(EventReceiverLifecycleAdapter, {
			RobloxEventReceiver = rbxEventReceiver,
			receiverComponents = {},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
