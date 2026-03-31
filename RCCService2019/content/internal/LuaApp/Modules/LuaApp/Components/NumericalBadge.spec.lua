return function()
	local NumericalBadge = require(script.Parent.NumericalBadge)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local createNumericalBadge = function(props)
		return mockServices({
			NumericalBadge = Roact.createElement(NumericalBadge, props)
		}, {
			includeThemeProvider = true,
		})
	end

	it("should create and destroy without errors when there's no badgeCount", function()
		local element = createNumericalBadge()

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when there's badgeCount", function()
		local element = createNumericalBadge({
			badgeCount = 10,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "NumericalBadge")
		expect(container.NumericalBadge.InnerBadge.Count.Text).to.equal("10")
		Roact.unmount(instance)
	end)
end