return function()
	local UnreadChatWidget = require(script.Parent.UnreadChatWidget)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("SHOULD mount, render, and unmount successfully", function()
		local element = mockServices({
			UnreadChatMessagesLabel = Roact.createElement(UnreadChatWidget),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end