return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local GamesProductInfo = require(Modules.LuaApp.Reducers.GamesProductInfo)
	local GameProductInfo = require(Modules.LuaApp.Models.GameProductInfo)
	local SetGamesProductInfo = require(Modules.LuaApp.Actions.SetGamesProductInfo)
	local TableUtilities = require(Modules.LuaApp.TableUtilities)

	describe("SetGamesProductInfo", function()
		it("should preserve purity", function()
			local oldState = GamesProductInfo(nil, {})
			local newState = GamesProductInfo(oldState, SetGamesProductInfo({}))

			expect(oldState).to.never.equal(newState)
		end)

		it("should add game details", function()
			local gameProductInfo1 = GameProductInfo.mock("1")
			local gameProductInfo2 = GameProductInfo.mock("2")
			local gameProductInfo3 = GameProductInfo.mock("3")

			local oldState = GamesProductInfo({ ["1"] = gameProductInfo1 }, {})
			local newGamesProductInfo = {
				["2"] = gameProductInfo2,
				["3"] = gameProductInfo3,
			}
			local newState = GamesProductInfo(oldState, SetGamesProductInfo(newGamesProductInfo))

			expect(TableUtilities.FieldCount(newState)).to.equal(3)
			expect(TableUtilities.ShallowEqual(gameProductInfo1, newState["1"])).to.equal(true)
			expect(TableUtilities.ShallowEqual(gameProductInfo2, newState["2"])).to.equal(true)
			expect(TableUtilities.ShallowEqual(gameProductInfo3, newState["3"])).to.equal(true)
		end)
	end)
end