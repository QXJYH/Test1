return function()
	local UnreadChatMessagesLabel = require(script.Parent.UnreadChatMessagesLabel)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("SHOULD mount, render, and unmount successfully", function()
		local element = mockServices({
			UnreadChatMessagesLabel = Roact.createElement(UnreadChatMessagesLabel),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("SHOULD render when UnreadMessageCount is defined", function()
		local conversationModel = {
			hasUnreadMessages = true,
		}
		local store = Rodux.Store.new(AppReducer, {
			ChatAppReducer = {
				Conversations = {
					conversationModel
				},
			},
		})

		local element = mockServices({
			UnreadChatMessagesLabel = Roact.createElement(UnreadChatMessagesLabel),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			store = store,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "test")

		expect(container:FindFirstChild("test").ClassName).to.equal("TextLabel")
		expect(container:FindFirstChild("test").Text).to.equal("1 Unread")
		Roact.unmount(instance)
	end)
end