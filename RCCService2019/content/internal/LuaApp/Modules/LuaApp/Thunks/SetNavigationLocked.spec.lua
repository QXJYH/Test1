return function()
	local SetNavigationLocked = require(script.Parent.SetNavigationLocked)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)

	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()
	if not FFlagLuaNavigationLockRefactor then
		return
	end

	it("should do nothing if lock state hasn't changed", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Home } },
				},
				lockNavigationActions = false,
			},
		})

		store:dispatch(SetNavigationLocked(false))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(state.lockNavigationActions).to.equal(false)
	end)

	it("should clear locked state if asked", function()
		local store = MockStore.new({
			Navigation = {
				history = {
					{ { name = AppPage.Home } },
				},
				lockNavigationActions = true,
			},
		})

		store:dispatch(SetNavigationLocked(false))

		local state = store:getState().Navigation
		expect(#state.history).to.equal(1)
		expect(state.lockNavigationActions).to.equal(false)
	end)
end
