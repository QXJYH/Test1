return function()
	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Cryo = require(CorePackages.Cryo)
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local IconTextBar = require(Modules.LuaApp.Components.Generic.IconTextBar)

	local sampleAsset = "LuaApp/buttons/buttonFill"

	local EXAMPLE_PROPS = {
		layoutOrder = 1,
		padding = {
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
		},
		icon = sampleAsset,
		iconSize = 20,
		gutterSize = 20,
		textKey = "Feature.GameDetails.Action.BuyRobux",
		textSize = 10,
	}

	it("should create and destroy without errors", function()
		local element = mockServices({
			IconTextBar = Roact.createElement(IconTextBar, EXAMPLE_PROPS),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props are passed down", function()
		local element = mockServices({
			IconTextBar = Roact.createElement(IconTextBar),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should not render icon if no icon is passed down", function()
		local props = Cryo.Dictionary.join(EXAMPLE_PROPS, {
			icon = Cryo.None,
		})
		local element = mockServices({
			Widget = Roact.createElement(IconTextBar, props),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("Icon", true) == nil).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should not render title text if no titleKey is passed down", function()
		local props = Cryo.Dictionary.join(EXAMPLE_PROPS, {
			titleKey = Cryo.None,
		})
		local element = mockServices({
			Widget = Roact.createElement(IconTextBar, props),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("Text", true) == nil).to.be.ok()

		Roact.unmount(instance)
	end)

end