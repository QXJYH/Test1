return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local IconButton = require(Modules.LuaApp.Components.IconButton)
	local ButtonState = require(script.Parent.Parent.Enum.ButtonState)
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
		local element = Roact.createElement(IconButton, {
			Size = UDim2.new(0, 8, 0, 8),
			Theme = theme,
			IconImage = "LuaApp/icons/ic-ROBUX",
			IconSize = UDim2.new(1, 0, 1, 0),
			IconPosition = UDim2.new(0.5, 0, 0.5, 0),
			IconAnchorPoint = Vector2.new(0.5, 0.5),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end