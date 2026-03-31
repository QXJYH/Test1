return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
    local TextButton = require(Modules.LuaApp.Components.TextButton)
	local ButtonState = require(script.Parent.Parent.Enum.ButtonState)
	local RoactServices = require(Modules.LuaApp.RoactServices)
	local theme = {
		TextFont = Enum.Font.SourceSans,
		[ButtonState.Default] = {
			Background = {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.5
			},
			Border = {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.3,
			},
			Content = {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.3,
			},
		}
	}

	it("should create and destroy without errors", function()
		local element = Roact.createElement(RoactServices.ServiceProvider, {
			TextButton = Roact.createElement(TextButton, {
				Size = UDim2.new(0, 8, 0, 8),
				Theme = theme,
				Text = "Common.Presence.Label.Online",
				TextSizeMin = 5,
				TextSizeMax = 20,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end