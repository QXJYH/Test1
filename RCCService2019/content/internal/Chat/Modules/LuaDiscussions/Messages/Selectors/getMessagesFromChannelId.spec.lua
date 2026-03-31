return function()
	local getMessagesFromChannelId = require(script.Parent.getMessagesFromChannelId)
	if true then return end
	describe("WHEN given a state and channelId", function()
		local mockChannelId = "mockChannelId"
		local message1 = {
			id = "message1",
			created = "2001",
		}
		local message2 = {
			id = "message2",
			created = "2002",
		}
		local message3 = {
			id = "message3",
			created = "2003",
		}
		local message4 = {
			id = "message4",
			created = "2004",
		}

		local mockState = {
			DiscussionsAppReducer = {
				channelMessages = {
					byId = {
						[message1.id] = message1,
						[message2.id] = message2,
						[message3.id] = message3,
						[message4.id] = message4,
					},

					byChannelId = {
						[mockChannelId] = { message1.id, message2.id, message3.id },
						anotherChannelId = { message4.id },
					},
				}
			}
		}
		local result = getMessagesFromChannelId(mockState, mockChannelId)

		it("SHOULD return a list of message models sorted by most recent last", function()
			expect(result[1]).to.equal(message1)
			expect(result[2]).to.equal(message2)
			expect(result[3]).to.equal(message3)
		end)

		it("SHOULD not include any message models that are not in the channelId", function()
			expect(result[4]).to.never.be.ok()
		end)
	end)
end