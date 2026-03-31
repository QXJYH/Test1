return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local IconCardList = require(script.Parent.IconCardList)
	local emptyTest = "Feature.Home.Message.NoChallenges"
	local iconUrls = {}
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")

	it("should create and destroy without errors", function()
		local element = mockServices({
			IconCardList = Roact.createElement(IconCardList, {
				emptyText = emptyTest,
				width = 600,
				iconUrls = iconUrls,
				cardBorderSizePixel = 1,
				cardBackgroundColor = Color3.fromRGB(200, 200, 200),
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy an empty card list without errors", function()
		local element = mockServices({
			IconCardList = Roact.createElement(IconCardList, {
				emptyText = emptyTest,
				width = 500,
				cardBorderSizePixel = 1,
				cardBackgroundColor = Color3.fromRGB(200, 200, 200),
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end