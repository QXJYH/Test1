return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local PrimaryStatWidget = require(Modules.LuaApp.Components.PrimaryStatWidget)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(PrimaryStatWidget, {
			icon = "",
			number = "31K",
			label = "2B",
			font = Enum.Font.SourceSans,
			color = Color3.fromRGB(255, 255, 255),
			width = 200,
			LayoutOrder = 1,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end