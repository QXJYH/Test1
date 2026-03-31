return function()
	local NavigateToRoute = require(script.Parent.NavigateToRoute)
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
					{ { name = AppPage.Home } }
				},
				lockTimer = lockTimer,
				lockNavigationActions = lockNavigationActions,
			},
		})
		store:dispatch(NavigateToRoute({ { name = AppPage.Games } }))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Home)
		expect(state.lockTimer).to.equal(lockTimer)
		expect(state.lockNavigationActions).to.equal(lockNavigationActions)
	end)

	it("should navigate to the new route", function()
		local store = MockStore.new()
		store:dispatch(NavigateToRoute({
			{ name = AppPage.Games },
			{ name = AppPage.GamesList, detail = "Popular" },
		}))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(AppPage.Games)
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		end
	end)

	it("should assert if given a non-table for route", function()
		NavigateToRoute({})

		expect(function()
			NavigateToRoute(nil)
		end).to.throw()

		expect(function()
			NavigateToRoute("Blargle!")
		end).to.throw()

		expect(function()
			NavigateToRoute(false)
		end).to.throw()

		expect(function()
			NavigateToRoute(0)
		end).to.throw()

		expect(function()
			NavigateToRoute(function() end)
		end).to.throw()
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should navigate to the new route even if locked when bypassNavigationLock is set", function()
			local store = MockStore.new({
				Navigation = {
					history = {
						{ { name = AppPage.Home } }
					},
					lockNavigationActions = true,
				},
			})

			store:dispatch(NavigateToRoute({
				{ name = AppPage.Games },
				{ name = AppPage.GamesList, detail = "Popular" },
			}, true))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(2)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Home)
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(AppPage.Games)
			expect(state.history[2][2].name).to.equal(AppPage.GamesList)
			expect(state.history[2][2].detail).to.equal("Popular")
			expect(state.lockNavigationActions).to.equal(true)
		end)

		it("should assert if given a non-boolean non-nil bypassNavigationLock", function()
			NavigateToRoute({}, nil)
			NavigateToRoute({}, true)
			NavigateToRoute({}, false)

			expect(function()
				NavigateToRoute({}, "Blargle!")
			end).to.throw()

			expect(function()
				NavigateToRoute({}, {})
			end).to.throw()

			expect(function()
				NavigateToRoute({}, 5)
			end).to.throw()

			expect(function()
				NavigateToRoute({}, function() end)
			end).to.throw()
		end)
	else
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			NavigateToRoute({}, nil)
			NavigateToRoute({}, 0)

			expect(function()
				NavigateToRoute({}, "Blargle!")
			end).to.throw()

			expect(function()
				NavigateToRoute({}, {})
			end).to.throw()

			expect(function()
				NavigateToRoute({}, false)
			end).to.throw()

			expect(function()
				NavigateToRoute({}, function() end)
			end).to.throw()
		end)
	end
end
