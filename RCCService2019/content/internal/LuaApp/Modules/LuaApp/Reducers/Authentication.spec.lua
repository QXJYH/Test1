return function()
	local Modules = game:GetService("CoreGui"):FindFirstChild("RobloxGui").Modules
	local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)

	describe("Authentication Reducer", function()
		it("should be able to set authentication status", function()
			local state = AppReducer(nil, {})
			expect(state.Authentication.status).to.equal(LoginStatus.UNKNOWN)
			state = AppReducer(state, SetAuthenticationStatus(LoginStatus.LOGGED_IN))
			expect(state.Authentication.status).to.equal(LoginStatus.LOGGED_IN)
		end)
	end)
end