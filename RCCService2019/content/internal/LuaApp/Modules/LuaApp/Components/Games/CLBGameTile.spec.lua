return function()
	local CLBGameTile = require(script.Parent.CLBGameTile)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testUniverseId = 1

	local function testCLBGameTile(dataInStore)
		local store = Rodux.Store.new(AppReducer, dataInStore)

		local element = mockServices({
			Item = Roact.createElement(CLBGameTile, {
				width = 100,
				universeId = testUniverseId,
				onActivated = function() end,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors when there are enough data", function()
		testCLBGameTile({
			GameDetails = { [testUniverseId] = { name = "test" } },
		})
	end)

	it("should create and destroy without errors when there's no data", function()
		testCLBGameTile(nil)
	end)
end
