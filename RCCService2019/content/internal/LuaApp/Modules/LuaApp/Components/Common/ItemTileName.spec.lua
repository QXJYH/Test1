return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local ItemTileName = require(script.Parent.ItemTileName)
	it("should create and destroy without errors", function()
		local testName = "some test name"
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 100),
			}, {
				ItemTileName = Roact.createElement(ItemTileName, {
					name = testName,
				})
			})
		}, {
			includeStyleProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy with loading statewithout errors", function()
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 100),
			}, {
				ItemTileName = Roact.createElement(ItemTileName, {
					name = nil,
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