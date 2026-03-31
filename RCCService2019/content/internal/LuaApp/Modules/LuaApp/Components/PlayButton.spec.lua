return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local PlayButtonStates = require(Modules.LuaApp.Enum.PlayButtonStates)
	local PlayButton = require(Modules.LuaApp.Components.PlayButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testPlayButton(playButtonState)
		local element = mockServices({
			PlayButton = Roact.createElement(PlayButton, {
				Size = UDim2.new(0, 30, 0, 30),
				LayoutOrder = 1,
				universeId = "10086",
				playButtonState = playButtonState,
				price = 25,
				onActivated = function() end,
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors in all possible PlayButtonStates", function()
		for _, playButtonState in pairs(PlayButtonStates) do
			testPlayButton(playButtonState)
		end
	end)
end