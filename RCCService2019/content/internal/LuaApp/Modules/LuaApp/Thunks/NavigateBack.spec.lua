return function()
	local NavigateBack = require(script.Parent.NavigateBack)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)

	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	it("should do nothing if navigation is locked", function()
		local lockTimer = 0
		local lockNavigationActions = nil
		if FFlagLuaNavigationLockRefactor then
			lockTimer = nil
			lockNavigationActions = false
		end

		local store = MockStore.new({
			Navigation = {
				history = {
					{
						{ name = AppPage.Games },
					},
					{
						{ name = AppPage.Games },
						{ name = AppPage.GamesList, detail = "Popular" },
					},
					{
						{ name = AppPage.Games },
						{ name = AppPage.GamesList, detail = "Popular" },
						{ name = AppPage.GameDetails, detail = "12345" },
					},
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})

		local actionLockTime = tick() + 1
		if FFlagLuaNavigationLockRefactor then
			store:dispatch(NavigateBack()) -- Expected to lock navigation!
		else
			store:dispatch(NavigateBack(actionLockTime))
		end
		store:dispatch(NavigateBack())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		else
			expect(state.lockTimer).to.equal(actionLockTime)
		end
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
					{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular" } },
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateBack())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)

		expect(state.lockTimer).to.equal(lockTimer)
		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		end
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should assert if given a non-nil non-boolean for bypassNavigationLock", function()
			NavigateBack(nil)
			NavigateBack(true)
			NavigateBack(false)

			expect(function()
				NavigateBack("Blargle!")
			end).to.throw()

			expect(function()
				NavigateBack({})
			end).to.throw()

			expect(function()
				NavigateBack(5)
			end).to.throw()

			expect(function()
				NavigateBack(function() end)
			end).to.throw()
		end)
	else
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			NavigateBack(nil)
			NavigateBack(0)

			expect(function()
				NavigateBack("Blargle!")
			end).to.throw()

			expect(function()
				NavigateBack({})
			end).to.throw()

			expect(function()
				NavigateBack(false)
			end).to.throw()

			expect(function()
				NavigateBack(function() end)
			end).to.throw()
		end)
	end
end
