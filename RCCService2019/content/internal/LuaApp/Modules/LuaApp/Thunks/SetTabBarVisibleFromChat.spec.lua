return function()
	local SetTabBarVisibleFromChat = require(script.Parent.SetTabBarVisibleFromChat)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)

	it("should do nothing if tab bar state hasn't changed", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Chat } },
				},
			},
			TabBarVisible = false,
		})

		store:dispatch(SetTabBarVisibleFromChat(false))
		expect(store:getState().TabBarVisible).to.equal(false)
	end)

	it("should do nothing if not under Chat page", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Home } },
				},
			},
			TabBarVisible = false,
		})

		store:dispatch(SetTabBarVisibleFromChat(true))
		expect(store:getState().TabBarVisible).to.equal(false)
	end)

	it("should change tab bar visibility under Chat page", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Chat } },
				},
			},
			TabBarVisible = false,
		})

		store:dispatch(SetTabBarVisibleFromChat(true))
		expect(store:getState().TabBarVisible).to.equal(true)
	end)
end
