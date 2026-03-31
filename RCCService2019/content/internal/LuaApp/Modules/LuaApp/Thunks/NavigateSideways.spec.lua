return function()
	local NavigateSideways = require(script.Parent.NavigateSideways)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)

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
		store:dispatch(NavigateSideways({ name = AppPage.GamesList, detail = "Featured" }))

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
					{ { name = AppPage.Games } },
					{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular" } },
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateSideways({ name = AppPage.GamesList, detail = "Featured" }))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(3)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Games)
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")
		expect(#state.history[3]).to.equal(2)
		expect(state.history[3][1].name).to.equal(AppPage.Games)
		expect(state.history[3][2].name).to.equal(AppPage.GamesList)
		expect(state.history[3][2].detail).to.equal("Featured")

		expect(state.lockTimer).to.equal(lockTimer)

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		end
	end)

	it("should assert if given a non-table for route", function()
		NavigateSideways({})

		expect(function()
			NavigateSideways(nil)
		end).to.throw()

		expect(function()
			NavigateSideways("Blargle!")
		end).to.throw()

		expect(function()
			NavigateSideways(false)
		end).to.throw()

		expect(function()
			NavigateSideways(0)
		end).to.throw()

		expect(function()
			NavigateSideways(function() end)
		end).to.throw()
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should navigate when locked if bypassNavigationLock is true", function()
			local store = MockStore.new({
				Navigation = {
					history = {
						{ { name = AppPage.Games } },
						{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockNavigationActions = true,
				},
			})
			store:dispatch(NavigateSideways({ name = AppPage.GamesList, detail = "Featured" }, true))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(3)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Games)
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(AppPage.Games)
			expect(state.history[2][2].name).to.equal(AppPage.GamesList)
			expect(state.history[2][2].detail).to.equal("Popular")
			expect(#state.history[3]).to.equal(2)
			expect(state.history[3][1].name).to.equal(AppPage.Games)
			expect(state.history[3][2].name).to.equal(AppPage.GamesList)
			expect(state.history[3][2].detail).to.equal("Featured")
			expect(state.lockNavigationActions).to.equal(true)
		end)

		it("should assert if given a non-nil non-boolean for bypassNavigationLock", function()
			NavigateSideways({}, nil)
			NavigateSideways({}, true)
			NavigateSideways({}, false)

			expect(function()
				NavigateSideways({}, "Blargle!")
			end).to.throw()

			expect(function()
				NavigateSideways({}, {})
			end).to.throw()

			expect(function()
				NavigateSideways({}, 5)
			end).to.throw()

			expect(function()
				NavigateSideways({}, function() end)
			end).to.throw()
		end)
	else
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			NavigateSideways({}, nil)
			NavigateSideways({}, 0)

			expect(function()
				NavigateSideways({}, "Blargle!")
			end).to.throw()

			expect(function()
				NavigateSideways({}, {})
			end).to.throw()

			expect(function()
				NavigateSideways({}, false)
			end).to.throw()

			expect(function()
				NavigateSideways({}, function() end)
			end).to.throw()
		end)
	end
end
