return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	it("should create and destroy without errors", function()
		local CarouselWidget = require(script.Parent.CarouselWidget)
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 100),
			}, {
				CarouselWidget = Roact.createElement(CarouselWidget, {
					layoutOrder = 1,
					onSeeAll = function()end,
					title = "testTitle",
					items = {},

					carouselHeight = 100,
					canvasWidth = 500,
					onChangeCanvasPosition = function()end,
					onRefCallback = function()end,
				})
			})
		}, {
			includeStyleProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end