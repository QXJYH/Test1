return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local UserAvatar = require(Modules.LuaApp.Components.Home.UserAvatar)

	it("should create and destroy without errors", function()
		local element = mockServices({
			UserAvatar = Roact.createElement(UserAvatar, {
				size = UDim2.new(1, 0, 1, 0),
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				sizeConstraint = Enum.SizeConstraint.RelativeYY,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with no props and empty store", function()
		local element = mockServices({
			UserAvatar = Roact.createElement(UserAvatar),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end