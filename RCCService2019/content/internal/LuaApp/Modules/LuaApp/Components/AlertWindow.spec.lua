return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testAlertWindowWithContainerWidth(containerWidth, componentWidth, hasCancelButton)
		local element = mockServices({
			AlertWindow = Roact.createElement(AlertWindow, {
				hasCancelButton = hasCancelButton,
				messageText = "testMessage",
				messageFont = Enum.Font.SourceSans,
				containerWidth = containerWidth,
			}),
		}, {
			includeLocalizationProvider = true,
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "AlertWindow")

		local outerFrame = container.AlertWindow
		expect(outerFrame ~= nil).to.equal(true)
		expect(outerFrame.Size.X.Offset).to.equal(componentWidth)

		Roact.unmount(instance)
	end

	it("should create and destroy without errors and create correct width with containerWidth", function()
		testAlertWindowWithContainerWidth(360, 320, false)
		testAlertWindowWithContainerWidth(500, 400, false)
		testAlertWindowWithContainerWidth(500, 400, true)
	end)
end