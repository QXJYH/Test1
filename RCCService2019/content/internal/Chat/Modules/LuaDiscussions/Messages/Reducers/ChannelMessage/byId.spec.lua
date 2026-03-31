return function()
	local byId = require(script.Parent.byId)

	local Messages = script:FindFirstAncestor("Messages")
	local GetChannelMessages = require(Messages.NetworkRequests.GetChannelMessages)

	local function mockResponse(messages)
		return {
			data = messages,
		}
	end

	describe("return value", function()
		it("should return a function", function()
			expect(byId).to.be.ok()
			expect(type(byId)).to.equal("function")
		end)

		it("should initialize with non-nil value", function()
			local state = byId(nil, {})

			expect(state).to.be.ok()
		end)
	end)

	describe("action GetChannelMessages.Succeeded", function()
		local mockChannelId = "mockChannelId"

		local mockId1 = "mockId1"
		local response1 = mockResponse({
			{
				created = "",
				id = mockId1,
				messageChunks = {},
			},
		})

		local action1 = GetChannelMessages.Succeeded(mockChannelId, response1)
		local state1 = byId(nil, action1)

		it("should add all channelMessages to state", function()
			expect(state1).to.be.ok()
			expect(state1[mockId1]).to.be.ok()
		end)

		-- Update existing state with new action
		local mockId2 = "mockId2"
		local mockId3 = "mockId3"
		local response2 = mockResponse({
			{
				created = "",
				id = mockId2,
				messageChunks = {},
			},
			{
				created = "",
				id = mockId3,
				messageChunks = {},
			},
		})

		local action2 = GetChannelMessages.Succeeded(mockChannelId, response2)
		local state2 = byId(state1, action2)

		it("should combine old state with new state", function()
			expect(state2).to.be.ok()

			-- Check previous message again
			expect(state2[mockId1]).to.be.ok()

			-- Check for new message
			expect(state2[mockId2]).to.be.ok()
			expect(state2[mockId3]).to.be.ok()
		end)

	end)

end
