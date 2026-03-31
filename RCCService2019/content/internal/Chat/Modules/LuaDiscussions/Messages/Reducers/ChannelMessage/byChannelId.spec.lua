return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Cryo = dependencies.Cryo
	local byChannelId = require(script.Parent.byChannelId)

	local Messages = script:FindFirstAncestor("Messages")
	local GetChannelMessages = require(Messages.NetworkRequests.GetChannelMessages)

	local function mockResponse(messages)
		return {
			data = messages,
		}
	end

	describe("return value", function()
		it("should return a function", function()
			expect(byChannelId).to.be.ok()
			expect(type(byChannelId)).to.equal("function")
		end)

		it("should initialize with non-nil value", function()
			local state = byChannelId(nil, {})

			expect(state).to.be.ok()
		end)
	end)

	describe("action GetChannelMessages.Succeeded", function()
		local mockChannelId = "mockChannelId"

		local mockId1 = "mockId1"
		local response1 = mockResponse({
			{
				id = mockId1,
			},
		})

		local action1 = GetChannelMessages.Succeeded({ mockChannelId }, response1)
		local state1 = byChannelId(nil, action1)

		it("should add all channelMessages to state", function()
			expect(state1).to.be.ok()
			expect(state1[mockChannelId]).to.be.ok()

			expect(Cryo.List.find(state1[mockChannelId], mockId1)).to.be.ok()
		end)

		-- Update existing state with new action
		local mockId2 = "mockId2"
		local mockId3 = "mockId3"
		local response2 = mockResponse({
			{
				id = mockId2,
			},
			{
				id = mockId3,
			},
		})

		local action2 = GetChannelMessages.Succeeded({ mockChannelId }, response2)
		local state2 = byChannelId(state1, action2)

		it("should combine old state with new state", function()
			expect(state2).to.be.ok()

			-- Check previous message again
			expect(Cryo.List.find(state2[mockChannelId], mockId1)).to.be.ok()

			-- Check for new message
			expect(Cryo.List.find(state2[mockChannelId], mockId2)).to.be.ok()
			expect(Cryo.List.find(state2[mockChannelId], mockId3)).to.be.ok()
		end)
	end)

end