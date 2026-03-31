return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local FramePopup = require(Modules.LuaApp.Components.FramePopup)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local listContents = {}
	listContents["Layout"] = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Name = "Layout",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			ScreenSize = Vector2.new(800, 600),
		})
		local element = mockServices({
			framePopUp = Roact.createElement(FramePopup, {
				heightScrollContainer = 50,
				onCancel = nil,
			}, listContents)
		}, {
			store = store,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end
