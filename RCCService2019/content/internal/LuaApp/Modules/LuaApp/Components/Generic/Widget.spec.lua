return function()
	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Cryo = require(CorePackages.Cryo)
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local Widget = require(Modules.LuaApp.Components.Generic.Widget)
	local Colors = require(Modules.LuaApp.Themes.Colors)

	local IMAGE = "LuaApp/icons/ic-ROBUX"
	local ROBUX_TITLE_KEY = "Feature.GameDetails.Action.BuyRobux"

	local numberOfRendersOfDummyRenderContent = 0
	local function dummyRenderContent()
		numberOfRendersOfDummyRenderContent = numberOfRendersOfDummyRenderContent + 1
		return Roact.createElement("Frame")
	end

	local EXAMPLE_WIDGET_PROPS = {
		layoutOrder = 1,
		titlePadding = {
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
		},
		contentPadding = {
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
		},
		backgroundImage = IMAGE,
		backgroundColor = Colors.White,
		backgroundTransparency = 0.5,
		icon = IMAGE,
		iconSize = 10,
		titleGutterSize = 6,
		titleKey = ROBUX_TITLE_KEY,
		titleSize = 4,
		titleColor = Colors.White,
		renderContent = dummyRenderContent,
	}

	it("should create and destroy without errors", function()
		local element = mockServices({
			Widget = Roact.createElement(Widget, EXAMPLE_WIDGET_PROPS),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should not throw if no props are passed down", function()
		local element = mockServices({
			Widget = Roact.createElement(Widget),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render with provided render function properly for its content", function()
		local prevNumberOfRendersOfDummyRenderContent = numberOfRendersOfDummyRenderContent

		local element = mockServices({
			Widget = Roact.createElement(Widget, EXAMPLE_WIDGET_PROPS),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")
		local content = container.Test:FindFirstChild("ContentFrame")

		expect(content).to.be.ok()
		expect(numberOfRendersOfDummyRenderContent - prevNumberOfRendersOfDummyRenderContent).to.equal(1)

		Roact.unmount(instance)
	end)

	it("should not render content if no content render function is passed down", function()
		local widgetProps = Cryo.Dictionary.join(EXAMPLE_WIDGET_PROPS, {
			renderContent = Cryo.None,
		})
		local element = mockServices({
			Widget = Roact.createElement(Widget, widgetProps),
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("ContentFrame", true)).to.equal(nil)

		Roact.unmount(instance)
	end)

end