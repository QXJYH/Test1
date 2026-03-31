return function()
	local NavigateDown = require(script.Parent.NavigateDown)
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
		store:dispatch(NavigateDown({ name = AppPage.GamesList, detail = "Popular" }))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Home)
		expect(state.lockTimer).to.equal(lockTimer)
		expect(state.lockNavigationActions).to.equal(lockNavigationActions)
	end)

	it("should navigate to new page by appending to the last route", function()
		local store = MockStore.new()
		store:dispatch(NavigateDown({ name = AppPage.GamesList, detail = "Popular" }))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(2)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
		expect(#state.history[2]).to.equal(2)
		expect(state.history[2][1].name).to.equal(FlagSettings.GetDefaultAppPage())
		expect(state.history[2][2].name).to.equal(AppPage.GamesList)
		expect(state.history[2][2].detail).to.equal("Popular")

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(true)
		end
	end)

	if FlagSettings.IsLuaGameDetailsPageEnabled() then
		it("should not be marked as a native wrapper if it's a GameDetails page and lua game details is on", function()
			local store = MockStore.new()
			local page = { name = AppPage.GameDetail, detail = "12345" }
			store:dispatch(NavigateDown(page))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(2)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(FlagSettings.GetDefaultAppPage())
			expect(state.history[2][2].name).to.equal(AppPage.GameDetail)
			expect(state.history[2][2].detail).to.equal("12345")
			expect(state.history[2][2].nativeWrapper).to.equal(nil)

			if FFlagLuaNavigationLockRefactor then
				expect(state.lockTimer).to.equal(nil)
				expect(state.lockNavigationActions).to.equal(true)
			else
				expect(state.lockNavigationActions).to.equal(nil)
			end
		end)
	else
		it("should be marked as a native wrapper with a timeout if it's a GameDetails page", function()
			local store = MockStore.new()
			local page = { name = AppPage.GameDetail, detail = "12345" }
			store:dispatch(NavigateDown(page))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(2)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Home)
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(AppPage.Home)
			expect(state.history[2][2].name).to.equal(AppPage.GameDetail)
			expect(state.history[2][2].detail).to.equal("12345")
			expect(state.history[2][2].nativeWrapper).to.equal(true)

			if FFlagLuaNavigationLockRefactor then
				expect(state.lockTimer).to.equal(nil)
				expect(state.lockNavigationActions).to.equal(true)
			else
				expect(state.lockTimer > 0).to.equal(true)
				expect(state.lockNavigationActions).to.equal(nil)
			end
		end)
	end

	it("should assert if given a non-table for route", function()
		NavigateDown({})

		expect(function()
			NavigateDown(nil)
		end).to.throw()

		expect(function()
			NavigateDown("Blargle!")
		end).to.throw()

		expect(function()
			NavigateDown(false)
		end).to.throw()

		expect(function()
			NavigateDown(0)
		end).to.throw()

		expect(function()
			NavigateDown(function() end)
		end).to.throw()
	end)

	if FFlagLuaNavigationLockRefactor then
		it("should navigate even if navigation is locked when bypassNavigationLock is true", function()
			local store = MockStore.new({
				Navigation = {
					history = {
						{ { name = AppPage.Home } }
					},
					lockNavigationActions = true,
				},
			})
			store:dispatch(NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, true))

			local state = store:getState().Navigation
			expect(#state.history).to.equal(2)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Home)
			expect(#state.history[2]).to.equal(2)
			expect(state.history[2][1].name).to.equal(AppPage.Home)
			expect(state.history[2][2].name).to.equal(AppPage.GamesList)
			expect(state.history[2][2].detail).to.equal("Popular")
			expect(state.lockNavigationActions).to.equal(true)
		end)

		it("should assert if given a non-nil non-boolean for bypassNavigationLock", function()
			NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, nil)
			NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, true)
			NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, false)

			expect(function()
				NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, "Blargle!")
			end).to.throw()

			expect(function()
				NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, {})
			end).to.throw()

			expect(function()
				NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, 5)
			end).to.throw()

			expect(function()
				NavigateDown({ name = AppPage.GamesList, detail = "Popular" }, function() end)
			end).to.throw()
		end)
	end
end
