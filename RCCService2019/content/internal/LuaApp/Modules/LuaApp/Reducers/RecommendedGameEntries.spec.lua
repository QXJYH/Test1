return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local SetRecommendedGameEntries = require(Modules.LuaApp.Actions.SetRecommendedGameEntries)
	local RecommendedGameEntries = require(Modules.LuaApp.Reducers.RecommendedGameEntries)
	local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)

	it("should be unmodified by other actions", function()
		local oldState = RecommendedGameEntries(nil, {})
		local newState = RecommendedGameEntries(oldState, { type = "not a real action" })

		expect(oldState).to.equal(newState)
	end)

	describe("SetRecommendedGameEntries", function()
		it("should preserve purity", function()
			local oldState = RecommendedGameEntries(nil, {})
			local newState = RecommendedGameEntries(oldState, SetRecommendedGameEntries("123", {}))

			expect(oldState).to.never.equal(newState)
		end)

		it("should set recommended game sort entries", function()
			local universeId = "123456"
			local testEntries = {
				GameSortEntry.mock("testId1"),
				GameSortEntry.mock("testId2"),
				GameSortEntry.mock("testId3")
			}

			local defaultState = RecommendedGameEntries(nil, {})
			expect(defaultState[universeId]).to.equal(nil)

			-- modify the store
			local action = SetRecommendedGameEntries(universeId, testEntries)
			local modifiedState = RecommendedGameEntries(defaultState, action)

			-- check the store now contains the correct data
			expect(modifiedState[universeId]).to.equal(testEntries)
		end)
	end)
end