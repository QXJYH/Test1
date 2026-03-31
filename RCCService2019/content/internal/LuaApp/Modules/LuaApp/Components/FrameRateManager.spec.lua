return function()
	local FrameRateManager = require(script.Parent.FrameRateManager)
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(FrameRateManager)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
