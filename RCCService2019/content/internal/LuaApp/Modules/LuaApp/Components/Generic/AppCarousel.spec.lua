return function()
	local AppCarousel = require(script.Parent.AppCarousel)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)

	it("should create and destroy without errors", function()
		local items = {
			test1 = Roact.createElement("Frame", {
				Size = UDim2.new(0, 50, 0, 50),
			}),
			test2 = Roact.createElement("Frame", {
				Size = UDim2.new(0, 50, 0, 50),
			})
		}
		local element = Roact.createElement(AppCarousel, {
			carouselHeight = 50,
			canvasWidth = 500,
			onChangeCanvasPosition = function()end,
			onRefCallback = function()end,
			items = items,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
