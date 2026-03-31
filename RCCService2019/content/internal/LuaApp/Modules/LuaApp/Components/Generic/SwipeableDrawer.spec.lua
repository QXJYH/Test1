return function()
	local SwipeableDrawer = require(script.Parent.SwipeableDrawer)
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	describe("SwipeableDrawer", function()
		it("should create/destroy/update without errors", function()
			local element = Roact.createElement(SwipeableDrawer, {
				Size = UDim2.new(0, 500, 0, 500),
				startPosition = 400,
				containerHeight = 500,
			}, {
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 1000),
				}),
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
