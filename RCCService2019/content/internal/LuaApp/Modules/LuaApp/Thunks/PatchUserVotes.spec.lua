return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)
	local getNewGameVotes = require(script.Parent.PatchUserVotes).getNewGameVotes

	local gameVotes = {
		upVotes = 1,
		downVotes = 1,
	}

	describe("PatchUserVotes.getNewGameVotes", function()
		it("should return correct GameVote info", function()
			local newGameVotes = getNewGameVotes(gameVotes, VoteStatus.NotVoted, VoteStatus.NotVoted)
			expect(newGameVotes.upVotes).to.equal(1)
			expect(newGameVotes.downVotes).to.equal(1)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.NotVoted, VoteStatus.VotedUp)
			expect(newGameVotes.upVotes).to.equal(2)
			expect(newGameVotes.downVotes).to.equal(1)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.NotVoted, VoteStatus.VotedDown)
			expect(newGameVotes.upVotes).to.equal(1)
			expect(newGameVotes.downVotes).to.equal(2)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedUp, VoteStatus.NotVoted)
			expect(newGameVotes.upVotes).to.equal(0)
			expect(newGameVotes.downVotes).to.equal(1)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedUp, VoteStatus.VotedUp)
			expect(newGameVotes.upVotes).to.equal(1)
			expect(newGameVotes.downVotes).to.equal(1)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedUp, VoteStatus.VotedDown)
			expect(newGameVotes.upVotes).to.equal(0)
			expect(newGameVotes.downVotes).to.equal(2)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedDown, VoteStatus.NotVoted)
			expect(newGameVotes.upVotes).to.equal(1)
			expect(newGameVotes.downVotes).to.equal(0)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedDown, VoteStatus.VotedUp)
			expect(newGameVotes.upVotes).to.equal(2)
			expect(newGameVotes.downVotes).to.equal(0)

			newGameVotes = getNewGameVotes(gameVotes, VoteStatus.VotedDown, VoteStatus.VotedDown)
			expect(newGameVotes.upVotes).to.equal(1)
			expect(newGameVotes.downVotes).to.equal(1)
		end)
	end)
end