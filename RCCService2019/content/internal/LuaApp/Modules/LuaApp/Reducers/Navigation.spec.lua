return function()
	local Navigation = require(script.Parent.Navigation)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Cryo = require(CorePackages.Cryo)
	local AppPage = require(Modules.LuaApp.AppPage)
	local ApplyNavigateToRoute = require(Modules.LuaApp.Actions.ApplyNavigateToRoute)
	local ApplyNavigateBack = require(Modules.LuaApp.Actions.ApplyNavigateBack)
	local ApplyNavigateUp = require(Modules.LuaApp.Actions.ApplyNavigateUp)
	local ApplyResetNavigationHistory = require(Modules.LuaApp.Actions.ApplyResetNavigationHistory)
	local ApplySetNavigationLocked = require(Modules.LuaApp.Actions.ApplySetNavigationLocked)
	local FlagSettings = require(Modules.LuaApp.FlagSettings)

	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	it("should have a single route to the default page", function()
		local state = Navigation(nil, {})
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(false)
			expect(state.lockTimer).to.equal(nil)
		else
			expect(state.lockNavigationActions).to.equal(nil)
			expect(state.lockTimer).to.equal(0)
		end
	end)

	it("should be unchanged by other actions", function()
		local state = Navigation(nil, {})
		state = Navigation(state, { type = "not a navigation action" })

		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())

		if FFlagLuaNavigationLockRefactor then
			expect(state.lockNavigationActions).to.equal(false)
			expect(state.lockTimer).to.equal(nil)
		else
			expect(state.lockNavigationActions).to.equal(nil)
			expect(state.lockTimer).to.equal(0)
		end
	end)

	describe("ApplyNavigateToRoute", function()
		it("should set the next route", function()
			local state = Navigation(nil, {})
			state = Navigation(state, ApplyNavigateToRoute({
				{ name = AppPage.Games },
				{ name = AppPage.GamesList, detail = "Popular" }
			}))

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

		it("should clear history if the route is a root page", function()
			local state = Navigation(nil, {})
			state = Navigation(state, ApplyNavigateToRoute({ { name = AppPage.Games } }))

			expect(#state.history).to.equal(1)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Games)

			if FFlagLuaNavigationLockRefactor then
				expect(state.lockNavigationActions).to.equal(true)
			end
		end)

		if FFlagLuaNavigationLockRefactor then
			it("should lock out navigation after ApplyNavigateToRoute", function()
				local state = Navigation(nil, {})
				state = Navigation(state, ApplyNavigateToRoute({ { name = AppPage.Games } }))

				expect(state.lockNavigationActions).to.equal(true)
			end)
		else
			it("should store the timeout value", function()
				local state = Navigation(nil, {})
				state = Navigation(state, ApplyNavigateToRoute({ { name = AppPage.Games } }, 11113))

				expect(state.lockTimer).to.equal(11113)
			end)

			it("should not set the timeout value if unspecified", function()
				local state = Navigation(nil, {})
				state = Cryo.Dictionary.join(state, { lockTimer = 11115 })
				state = Navigation(state, ApplyNavigateToRoute({ { name = AppPage.Games } }))

				expect(state.lockTimer).to.equal(11115)
			end)
		end
	end)

	describe("ApplyNavigateBack", function()
		it("should go back to the previous route", function()
			local state = {
				history = {
					{ { name = AppPage.Home } },
					{ { name = AppPage.Home }, { name = AppPage.GamesList, detail = "Popular" } },
				},
				lockTimer = 0,
			}
			state = Navigation(state, ApplyNavigateBack())

			expect(#state.history).to.equal(1)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(AppPage.Home)
		end)

		it("should do nothing if there's only one route in the history", function()
			local state = Navigation(nil, {})
			state = Navigation(state, ApplyNavigateBack())

			expect(#state.history).to.equal(1)
			expect(#state.history[1]).to.equal(1)
			expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
		end)

		if FFlagLuaNavigationLockRefactor then
			it("should lock out navigation after ApplyNavigateBack", function()
				local state = Navigation({
					history = {
						{ { name = AppPage.Games } },
						{ { name = AppPage.Games }, { name = AppPage.Home } }
					},
					lockNavigationActions = false
				}, {})
				state = Navigation(state, ApplyNavigateBack())

				expect(state.lockNavigationActions).to.equal(true)
			end)
		else
			it("should store the timeout value", function()
				local state = {
					history = {
						{ { name = AppPage.Home } },
						{ { name = AppPage.Home }, { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockTimer = 0,
				}
				state = Navigation(state, ApplyNavigateBack(12113))

				expect(state.lockTimer).to.equal(12113)
			end)

			it("should not set the timeout value if unspecified", function()
				local state = {
					history = {
						{ { name = AppPage.Home } },
						{ { name = AppPage.Home }, { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockTimer = 0,
				}
				state = Cryo.Dictionary.join(state, { lockTimer = 13311 })
				state = Navigation(state, ApplyNavigateBack())

				expect(state.lockTimer).to.equal(13311)
			end)
		end
	end)

	if FFlagLuaNavigationLockRefactor then
		describe("ApplyNavigateUp", function()
			it("should append default route to history, if only one page in current route", function()
				local state = {
					history = {
						{ { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockNavigationActions = false,
				}

				state = Navigation(state, ApplyNavigateUp())
				expect(#state.history).to.equal(2)
				expect(state.history[2][1].name).to.equal(FlagSettings.GetDefaultAppPage())
				expect(state.lockNavigationActions).to.equal(true)
			end)

			it("should jump one page up in route and append to history if more than one page in current route", function()
				local state = {
					history = {
						{ { name = AppPage.Games }, { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockNavigationActions = false,
				}

				state = Navigation(state, ApplyNavigateUp())
				expect(#state.history).to.equal(2)
				expect(#state.history[2]).to.equal(1)
				expect(state.history[2][1].name).to.equal(AppPage.Games)
				expect(state.lockNavigationActions).to.equal(true)
			end)
		end)

		describe("ApplyResetNavigationHistory", function()
			it("should reset to default route if no route is provided", function()
				local state = {
					history = {
						{ { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockNavigationActions = false,
				}

				state = Navigation(state, ApplyResetNavigationHistory())
				expect(#state.history).to.equal(1)
				expect(#state.history[1]).to.equal(1)
				expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
				expect(state.lockNavigationActions).to.equal(true)
			end)

			it("should reset to provided route", function()
				local state = {
					history = {
						{ { name = AppPage.GamesList, detail = "Popular" } },
					},
					lockNavigationActions = false,
				}

				local customRoute = { { name = AppPage.Games } }
				state = Navigation(state, ApplyResetNavigationHistory(customRoute))
				expect(#state.history).to.equal(1)
				expect(#state.history[1]).to.equal(1)
				expect(state.history[1][1].name).to.equal(AppPage.Games)
				expect(state.lockNavigationActions).to.equal(true)
			end)
		end)

		describe("ApplySetNavigationLocked", function()
			it("should do nothing if lock state hasn't changed", function()
				local state = {
					history = {
						{ { name = AppPage.Home } },
					},
					lockNavigationActions = false,
				}

				state = Navigation(state, ApplySetNavigationLocked(false))
				expect(#state.history).to.equal(1)
				expect(#state.history[1]).to.equal(1)
				expect(state.history[1][1].name).to.equal(AppPage.Home)
				expect(state.lockNavigationActions).to.equal(false)
			end)

			it("should clear lock if asked", function()
				local state = {
					history = {
						{ { name = AppPage.Home } },
					},
					lockNavigationActions = true,
				}

				state = Navigation(state, ApplySetNavigationLocked(false))
				expect(#state.history).to.equal(1)
				expect(state.lockNavigationActions).to.equal(false)
			end)
		end)
	end
end
