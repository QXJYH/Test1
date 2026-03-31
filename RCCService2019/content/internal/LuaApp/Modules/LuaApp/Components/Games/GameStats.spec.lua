return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local GameStats = require(script.Parent.GameStats)
	it("should create and destroy without errors", function()
		local playerCount = 12345
		local totalUpVotes = 98765
		local totalDownVotes = 43210
		local element = mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 1000, 0, 1000),
			}, {
				GameStats = Roact.createElement(GameStats, {
					playerCount = playerCount,
					totalUpVotes = totalUpVotes,
					totalDownVotes = totalDownVotes,
				})
			})
		}, {
			includeStyleProvider = true,
			includeLocalizationProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end