return function()
	local MorePageScrollingFrame = require(script.Parent.MorePageScrollingFrame)
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MorePageScrollingFrame)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
