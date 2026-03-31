return function()
	local sortChannelMessagesAscending = require(script.Parent.sortChannelMessagesAscending)

	describe("WHEN given an array of channelMessages", function()
		it("SHOULD sort two channelMessages in chronological order, most recent last", function()
			local message1 = {
				created = "2001-01-01T00:00:00+0000",
			}
			local message2 = {
				created = "2002-01-01T00:00:00+0000",
			}
			local result = sortChannelMessagesAscending({
				message2, message1,
			})

			expect(result[1]).to.equal(message1)
			expect(result[2]).to.equal(message2)
		end)

		it("SHOULD sort four channelMessages in chronological order, most recent last", function()
			local message1 = {
				created = "2001-01-01T00:00:00+0000",
			}
			local message2 = {
				created = "2002-01-01T00:00:00+0000",
			}
			local message3 = {
				created = "2003-01-01T00:00:00+0000",
			}
			local message4 = {
				created = "2004-01-01T00:00:00+0000",
			}
			local result = sortChannelMessagesAscending({
				message4, message1, message3, message2,
			})

			expect(result[1]).to.equal(message1)
			expect(result[2]).to.equal(message2)
			expect(result[3]).to.equal(message3)
			expect(result[4]).to.equal(message4)
		end)
	end)
end