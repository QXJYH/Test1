return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local ItemTileIcon = require(script.Parent.ItemTileIcon)
	it("should create and destroy without errors", function()
		local testImage = "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814"
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 100),
			}, {
				ItemTileIcon = Roact.createElement(ItemTileIcon, {
					image = testImage,
				})
			})
		}, {
			includeStyleProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end