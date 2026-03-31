return function()
	local Modules = game:GetService("CoreGui"):FindFirstChild("RobloxGui").Modules
	local NextDataExpirationTime = require(script.parent.NextDataExpirationTime)
	local SetNextDataExpirationTime = require(Modules.LuaApp.Actions.SetNextDataExpirationTime)

	it("Should not be mutated by other actions", function()
		local oldState = NextDataExpirationTime(nil, {})
		local newState = NextDataExpirationTime(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetNextDataExpirationTime", function()
		it("should preserve purity", function()
			local oldState = NextDataExpirationTime(nil, {})
			local newState = NextDataExpirationTime(oldState, SetNextDataExpirationTime("GameDetails1", 10))
			expect(oldState).to.never.equal(newState)
		end)

		it("should correctly update next data expiration time", function()
			local oldState = NextDataExpirationTime({ ["GameDetails1"] = 10 }, {})
			local newState = NextDataExpirationTime(oldState, SetNextDataExpirationTime("GameDetails2", 20))
			expect(newState["GameDetails1"]).to.equal(10)
			expect(newState["GameDetails2"]).to.equal(20)
		end)
	end)
end