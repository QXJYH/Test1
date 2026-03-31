return function()
	local policyReader = require(script.Parent.PolicyReader)

	local mockPolicy = {
		ChatConversationHeaderGroupDetails = false,
		ChatHeaderSearch = true,
		ChatHeaderCreateChatGroup = function(params)
			return params.chatGroup and true or false
		end,
		ChatHeaderNotifications = function(params)
			return function(curLocation)
				return curLocation == "Sichuan"
			end
		end,
	}

	describe("PolicyReader", function()
		it("should generate feature functions correctly", function()
			local params = {
				chatGroup = true,
			}
			local target = {}
			policyReader.generateFeatureFunctions(mockPolicy, params, target)

			expect(target.getChatConversationHeaderGroupDetails()).to.equal(false)
			expect(target.getChatHeaderSearch()).to.equal(true)
			expect(target.getChatHeaderCreateChatGroup()).to.equal(true)
			expect(target.getChatHeaderNotifications("Shanghai")).to.equal(false)
		end)

		it("IsFeatureEnabled() should work correctly", function()
			expect(policyReader.IsFeatureEnabled(mockPolicy, "ChatConversationHeaderGroupDetails", {})).to.equal(false)
			expect(policyReader.IsFeatureEnabled(mockPolicy, "ChatHeaderSearch", {})).to.equal(true)
		end)

		it("should get feature correctly by default ", function()
			local params = {
				chatGroup = true,
			}
			local target = {}
			policyReader.generateFeatureFunctions(mockPolicy, params, target)

			expect(target.getRecommendedGames()).to.equal(true)
			expect(target.getUseWidthBasedFormFactorRule()).to.equal(false)

			expect(policyReader.IsFeatureEnabled(mockPolicy, "RecommendedGames", {})).to.equal(true)
		end)
	end)
end