return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local FullscreenPageWithSafeArea = require(script.Parent.FullscreenPageWithSafeArea)

	local function mockStore()
		return Rodux.Store.new(AppReducer, {
			ScreenSize = Vector2.new(600, 300),
			GlobalGuiInset = {
				left = 10,
				top = 5,
				right = 10,
				bottom = 5,
			},
			TopBar = {
				statusBarHeight = 20,
			},
		})
	end

	it("should create and destroy without errors", function()
		local store = mockStore()

		local element = mockServices({
			FullscreenPageWithSafeArea = Roact.createElement(FullscreenPageWithSafeArea),
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when include status bar", function()
		local store = mockStore()

		local element = mockServices({
			FullscreenPageWithSafeArea = Roact.createElement(FullscreenPageWithSafeArea, {
				includeStatusBar = true,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when store is not set (default state)", function()
		local store = Rodux.Store.new(AppReducer)

		local element = mockServices({
			FullscreenPageWithSafeArea = Roact.createElement(FullscreenPageWithSafeArea),
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end