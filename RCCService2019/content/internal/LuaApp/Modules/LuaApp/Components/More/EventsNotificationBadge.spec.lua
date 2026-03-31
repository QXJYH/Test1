return function()
	local EventsNotificationBadge = require(script.Parent.EventsNotificationBadge)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)

	it("should create and destroy without errors when there's no event", function()
		local element = Roact.createElement(EventsNotificationBadge)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when there's event", function()
		local element = Roact.createElement(EventsNotificationBadge, {
			badgeCount = 10,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "EventsCount")
		expect(container.EventsCount.Text).to.equal("10")
		Roact.unmount(instance)
	end)
end