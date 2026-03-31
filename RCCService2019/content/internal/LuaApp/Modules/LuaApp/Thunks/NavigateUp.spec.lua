return function()
	local NavigateUp = require(script.Parent.NavigateUp)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppPage = require(Modules.LuaApp.AppPage)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)

	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	it("should do nothing if navigation is locked", function()
		local lockTimer = tick() + 1
		local lockNavigationActions = nil
		if FFlagLuaNavigationLockRefactor then
			lockTimer = nil
			lockNavigationActions = true
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
		store:dispatch(NavigateUp())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")
		expect(state.lockTimer).to.equal(lockTimer)
		expect(state.lockNavigationActions).to.equal(lockNavigationActions)
	end)

	it("should navigate to new page by removing the last element of the current route", function()
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
						{ name = AppPage.GamesList, detail = "Popular" },
						{ name = AppPage.GameDetails, detail = "12345" },
					},
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateUp())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(3)
		expect(state.history[1][1].name).to.equal(AppPage.Games)
		expect(state.history[1][2].name).to.equal(AppPage.GamesList)
		expect(state.history[1][2].detail).to.equal("Popular")
		expect(state.history[1][3].name).to.equal(AppPage.GameDetails)
		expect(state.history[1][3].detail).to.equal("12345")
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		else
			expect(state.lockTimer).to.equal(0)
		end
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should navigate even if locked when bypassNavigationLock is true", function()
			local store = MockStore.new({
				Navigation = {
					history = {
						{
							{ name = AppPage.Games },
							{ name = AppPage.GamesList, detail = "Popular" },
							{ name = AppPage.GameDetails, detail = "12345" },
						},
					},
					lockNavigationActions = true,
				},
			})
			store:dispatch(NavigateUp(true))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(2)
			expect(#state.history[1]).to.equal(3)
			expect(state.history[1][1].name).to.equal(AppPage.Games)
			expect(state.history[1][2].name).to.equal(AppPage.GamesList)
			expect(state.history[1][2].detail).to.equal("Popular")
			expect(state.history[1][3].name).to.equal(AppPage.GameDetails)
			expect(state.history[1][3].detail).to.equal("12345")
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(AppPage.Games)
			expect(state.history[2][2].name).to.equal(AppPage.GamesList)
			expect(state.history[2][2].detail).to.equal("Popular")
			expect(state.lockNavigationActions).to.equal(true)
		end)

		it("should assert if given a non-nil non-boolean for bypassNavigationLock", function()
			NavigateUp(nil)
			NavigateUp(true)
			NavigateUp(false)

			expect(function()
				NavigateUp("Blargle!")
			end).to.throw()

			expect(function()
				NavigateUp({})
			end).to.throw()

			expect(function()
				NavigateUp(5)
			end).to.throw()

			expect(function()
				NavigateUp(function() end)
			end).to.throw()
		end)
	else
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			NavigateUp(nil)
			NavigateUp(0)

			expect(function()
				NavigateUp("Blargle!")
			end).to.throw()

			expect(function()
				NavigateUp({})
			end).to.throw()

			expect(function()
				NavigateUp(false)
			end).to.throw()

			expect(function()
				NavigateUp(function() end)
			end).to.throw()
		end)
	end
end
