return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local ChannelMessageReducer = require(script.Parent.ChannelMessageReducer)

	local expectedFields = require(LuaDiscussions.UnitTestHelpers.expectedFields)

	describe("return value", function()
		it("should return a function", function()
			expect(ChannelMessageReducer).to.be.ok()
			expect(type(ChannelMessageReducer)).to.equal("function")
		end)

		it("has the expected fields, and only the expected fields", function()
			local state = ChannelMessageReducer(nil, {})

			expectedFields(state, {
				"byChannelId",
				"byId",
			})
		end)
	end)
end