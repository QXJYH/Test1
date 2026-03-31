return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local DiscussionsAppReducer = require(script.Parent.DiscussionsAppReducer)

	local expectedFields = require(LuaDiscussions.UnitTestHelpers.expectedFields)

	describe("return value", function()
		it("should return a function", function()
			expect(DiscussionsAppReducer).to.be.ok()
			expect(type(DiscussionsAppReducer)).to.equal("function")
		end)

		it("has the expected fields, and only the expected fields", function()
			local state = DiscussionsAppReducer(nil, {})

			expectedFields(state, {
				"channelMessages",
			})
		end)
	end)
end