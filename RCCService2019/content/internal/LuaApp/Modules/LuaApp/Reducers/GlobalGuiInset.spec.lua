return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local GlobalGuiInset = require(Modules.LuaApp.Reducers.GlobalGuiInset)
	local SetGlobalGuiInset = require(Modules.LuaApp.Actions.SetGlobalGuiInset)
	local defaultGuiInset = {
		left = 0,
		top = 0,
		right = 0,
		bottom = 0,
	}

	it("should return default value when init", function()
		local state = GlobalGuiInset(nil, {})
		expect(type(state)).to.equal("table")
		expect(state.left).to.equal(defaultGuiInset.left)
		expect(state.top).to.equal(defaultGuiInset.top)
		expect(state.right).to.equal(defaultGuiInset.right)
		expect(state.bottom).to.equal(defaultGuiInset.bottom)
	end)

	it("should be unchanged by other actions", function()
		local oldState = GlobalGuiInset(nil, {})
		local newState = GlobalGuiInset(oldState, { type = "not SetGlobalGuiInset" })
		expect(newState).to.equal(oldState)
		expect(newState.left).to.equal(defaultGuiInset.left)
		expect(newState.top).to.equal(defaultGuiInset.top)
		expect(newState.right).to.equal(defaultGuiInset.right)
		expect(newState.bottom).to.equal(defaultGuiInset.bottom)
	end)

	it("should update GlobalGuiInset when dispatch SetGlobalGuiInset action", function()
		local newGuiInset = {
			left = 0,
			top = 0,
			right = 50,
			bottom = 50,
		}
		local action = SetGlobalGuiInset(newGuiInset.left, newGuiInset.top, newGuiInset.right, newGuiInset.bottom)
		local oldState = GlobalGuiInset(nil, {})
		local newState = GlobalGuiInset(oldState, action)
		expect(newState).never.to.equal(oldState)
		expect(newState.left).to.equal(newGuiInset.left)
		expect(newState.top).to.equal(newGuiInset.top)
		expect(newState.right).to.equal(newGuiInset.right)
		expect(newState.bottom).to.equal(newGuiInset.bottom)
	end)

	it("should assert if inputs are not 4 numbers", function()
		local oldState = GlobalGuiInset(nil, {})
		expect(function()
			GlobalGuiInset(oldState, SetGlobalGuiInset(nil, 0, 0, 0))
		end).to.throw()
		expect(function()
			GlobalGuiInset(oldState, SetGlobalGuiInset("", 0, 0, 0))
		end).to.throw()
		expect(function()
			GlobalGuiInset(oldState, SetGlobalGuiInset(true, 0, 0, 0))
		end).to.throw()
		expect(function()
			GlobalGuiInset(oldState, SetGlobalGuiInset({}, 0, 0, 0))
		end).to.throw()
		expect(function()
			GlobalGuiInset(oldState, SetGlobalGuiInset(function() end, 0, 0, 0))
		end).to.throw()
	end)
end