return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local HomePageIconListWidget = require(script.Parent.HomePageIconListWidget)
	local titleText = "CommonUI.Features.Label.Game"
	local titleIcon = "LuaApp/icons/challenge_games"
	local emptyTest = "Feature.Home.Message.NoChallenges"
	local iconUrls = {}
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")
	table.insert(iconUrls, "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814")

	it("should create and destroy without errors", function()
		local element = mockServices({
			HomePageIconListWidget = Roact.createElement(HomePageIconListWidget, {
				emptyText = emptyTest,
				width = 600,
				iconUrls = iconUrls,
				titleIcon = titleIcon,
				titleText = titleText,
				onActivated = function() end,
			})
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy an empty card list without errors", function()
		local element = mockServices({
			HomePageIconListWidget = Roact.createElement(HomePageIconListWidget, {
				emptyText = emptyTest,
				width = 600,
				titleIcon = titleIcon,
				titleText = titleText,
				onActivated = function() end,
			})
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end