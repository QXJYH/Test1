return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local ItemTile = require(script.Parent.ItemTile)
	it("should create and destroy without errors", function()
		local testImage = "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814"
		local testName = "some test name"
		local testStats = {
			playerCount = 12345,
			totalUpVotes = 98765,
			totalDownVotes = 43210,
		}
		local onActivated = function(...)end
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 100),
			}, {
				ItemTile = Roact.createElement(ItemTile, {
					thumbnail = testImage,
					name = testName,
					stats = testStats,
					width = 150,
					onActivated = onActivated,
					isSponsored = false,
					layoutOrder = 1,
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