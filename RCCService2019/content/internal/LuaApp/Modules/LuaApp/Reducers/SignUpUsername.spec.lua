return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local SignupUsername = require(Modules.LuaApp.Reducers.SignUpUsername)
	local SetSignupUsername = require(Modules.LuaApp.Actions.SetSignUpUsername)
	local defaultValue = ""
	it("should return default value when init", function()
		local state = SignupUsername(nil, {})
		expect(type(state)).to.equal("string")
		expect(state).to.equal(defaultValue)
	end)
	it("should be unchanged by other actions", function()
		local oldState = SignupUsername(nil, {})
		local newState = SignupUsername(oldState, { type = "not SetSignupUsername" })
		expect(newState).to.equal(oldState)
		expect(newState).to.equal(defaultValue)
	end)
	it("should update SignupUsername when dispatch SetSignupUsername action", function()
		local newValue = "Test"
		local oldState = SignupUsername(nil, {})
		local newState = SignupUsername(oldState, SetSignupUsername(newValue))
		expect(newState).never.to.equal(oldState)
		expect(newState).to.equal(newValue)
	end)
end