return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local LoadingSkeleton = require(Modules.LuaApp.Components.LoadingSkeleton)

	it("should create and destroy without errors", function()
		local element = mockServices({
			LoadingSkeleton = Roact.createElement(LoadingSkeleton, {
				createLayout = function() end,
				panels = {
					[1] = {
						Size = UDim2.new(0, 50, 0, 50)
					},
				},
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end