return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local GameInfoRow = require(Modules.LuaApp.Components.GameDetails.GameInfoRow)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy correctly with linkPage", function()
		local element = mockServices({
			GameInfoRow = Roact.createElement(GameInfoRow, {
                infoName = "Feature.GameDetails.Label.Developer",
                infoData = "Roblox",
                linkPage = "https://www.roblox.com",
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy correctly without linkPage", function()
		local element = mockServices({
			GameInfoRow = Roact.createElement(GameInfoRow, {
                infoName = "Feature.GameDetails.Label.Developer",
                infoData = "Roblox",
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
