return function()
	local ScrollingFrameWithExternalScrollBar = require(script.Parent.ScrollingFrameWithExternalScrollBar)
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	describe("ScrollingFrameWithExternalScrollBar", function()
		it("should create/destroy/update without errors", function()
			local element = Roact.createElement(ScrollingFrameWithExternalScrollBar, {
				Size = UDim2.new(0, 500, 0, 500),
				ScrollBarThickness = 5,
				scrollBarPositionOffsetX = 3,
				onlyRenderScrollBarOnHover = true,
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
