return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local Roact = require(Modules.Common.Roact)
	local ListCell = require(script.Parent.ListCell)

	it("should create and destroy without errors on phone", function()
		local item = {
			displayIcon = "rbxasset://textures/ui/LuaApp/icons/ic-chat20x20.png",
			text = "TestItem",
			onSelect = nil,
		}

		local element = mockServices({
			GameInfoRow = Roact.createElement(ListCell, {
				item = item,
				layoutOrder = 1,
			}),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end
