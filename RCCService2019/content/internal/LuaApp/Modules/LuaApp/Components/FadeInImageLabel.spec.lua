return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local FadeInImageLabel = require(Modules.LuaApp.Components.FadeInImageLabel)

	local image1 = "image1"
	local image2 = "image2"

	it("should create and destroy without errors", function()
		local element = Roact.createElement(FadeInImageLabel, {
			Image = image1,
			Size = UDim2.new(0, 50, 0, 50),
		})

		local instance = Roact.mount(element)

		Roact.reconcile(instance, Roact.createElement(FadeInImageLabel, {
			Image = image2,
			Size = UDim2.new(0, 50, 0, 50),
		}))

		Roact.unmount(instance)
	end)
end