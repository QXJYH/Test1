return function()
	local GameMediaItem = require(script.Parent.GameMediaItem)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			Item = Roact.createElement(GameMediaItem, {
				Size = UDim2.new(1, 0, 1, 0),
				Image = "",
				ImageTransparency = 0,
				isVideo = true,
				onImageLoaded = function() end,
				onActivated = function() end,
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
