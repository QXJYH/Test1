return function()
	local ResetNavigationHistory = require(script.Parent.ResetNavigationHistory)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)
	local FlagSettings = require(Modules.LuaApp.FlagSettings)

	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()
	if not FFlagLuaNavigationLockRefactor then
		return
	end

	it("should reset to provided route if present", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Games } }
				},
				lockNavigationActions = false,
			},
		})
		store:dispatch(ResetNavigationHistory({ { name = AppPage.Home } }))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(AppPage.Home)
		expect(state.lockNavigationActions).to.equal(true)
	end)

	it("should reset to default route if no route is provided", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Games } }
				},
				lockNavigationActions = false,
			},
		})
		store:dispatch(ResetNavigationHistory())

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(#state.history[1]).to.equal(1)
		expect(state.history[1][1].name).to.equal(FlagSettings.GetDefaultAppPage())
		expect(state.lockNavigationActions).to.equal(true)
	end)
end
