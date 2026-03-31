return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local UserAvatarRetryButton = require(Modules.LuaApp.Components.Home.UserAvatarRetryButton)

	it("should create and destroy without errors", function()
		local element = mockServices({
			UserAvatarRetryButton = Roact.createElement(UserAvatarRetryButton, {
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				maxTextWidth = 10,
				onRetry = function() end,
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
			UserAvatarRetryButton = Roact.createElement(UserAvatarRetryButton),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end