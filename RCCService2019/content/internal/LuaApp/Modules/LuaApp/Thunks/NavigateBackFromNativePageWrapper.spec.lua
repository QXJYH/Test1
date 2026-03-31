return function()
	local NavigateBackFromNativePageWrapper = require(script.Parent.NavigateBackFromNativePageWrapper)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)

	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	it("should do nothing if current view is not a native wrapper", function()
		local lockTimer = 0
		local lockNavigationActions = nil
		if FFlagLuaNavigationLockRefactor then
			lockTimer = nil
			lockNavigationActions = false
		end

		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Games } },
					{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular" } },
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateBackFromNativePageWrapper())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")
	end)

	it("should remove the current route from the history", function()
		local lockTimer = 0
		local lockNavigationActions = nil
		if FFlagLuaNavigationLockRefactor then
			lockTimer = nil
			lockNavigationActions = false
		end

		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Games } },
					{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular", nativeWrapper = true } },
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateBackFromNativePageWrapper())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		else
			expect(state.lockTimer).to.equal(lockTimer)
		end
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should remove the current route from the history even if navigation is locked", function()
			local store = MockStore.new({
				Navigation = {
					history = {
						{ { name = AppPage.Games } },
						{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular", nativeWrapper = true } },
					},
					lockNavigationActions = true,
				},
			})
			store:dispatch(NavigateBackFromNativePageWrapper())

			local state = store:getState().Navigation
			expect(#state.history).to.equal(1)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Games)
			expect(state.lockNavigationActions).to.equal(true)
		end)
	end
end
