return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local UserGameVotes = require(Modules.LuaApp.Reducers.UserGameVotes)
	local SetUserGameVotes = require(Modules.LuaApp.Actions.SetUserGameVotes)
	local ClearUserGameVotes = require(Modules.LuaApp.Actions.ClearUserGameVotes)
	local TableUtilities = require(Modules.LuaApp.TableUtilities)
	local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)

	local userVotes1 = {
		canVote = false,
		userVote = VoteStatus.NotVoted,
		reasonForNotVoteable = "",
	}

	local userVotes2 = {
		canVote = true,
		userVote = VoteStatus.VotedUp,
		reasonForNotVoteable = "",
	}

	describe("SetUserGameVotes", function()
		it("should preserve purity", function()
			local oldState = UserGameVotes(nil, {})
			local newState = UserGameVotes(oldState, SetUserGameVotes("", false, VoteStatus.NotVoted, ""))

			expect(oldState).to.never.equal(newState)
		end)

		it("should add user votes", function()
			local oldState = UserGameVotes({ ["1"] = userVotes1 }, {})
			local newState = UserGameVotes(oldState, SetUserGameVotes("2", userVotes2.canVote,
				userVotes2.userVote, userVotes2.reasonForNotVoteable))

			expect(TableUtilities.FieldCount(newState)).to.equal(2)
			expect(TableUtilities.ShallowEqual(userVotes1, newState["1"])).to.equal(true)
			expect(TableUtilities.ShallowEqual(userVotes2, newState["2"])).to.equal(true)
		end)
	end)

	describe("ClearUserGameVotes", function()
		it("should preserve purity", function()
			local oldState = UserGameVotes(nil, {})
			local newState = UserGameVotes(oldState, ClearUserGameVotes(""))

			expect(oldState).to.never.equal(newState)
		end)

		it("should clear user votes", function()
			local oldState = UserGameVotes({ ["1"] = userVotes1 }, {})
			local newState = UserGameVotes(oldState, ClearUserGameVotes("1"))

			expect(TableUtilities.FieldCount(newState)).to.equal(0)
			expect(newState["1"]).to.equal(nil)
		end)
	end)
end