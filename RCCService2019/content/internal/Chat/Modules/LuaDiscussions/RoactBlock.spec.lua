return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local RoactBlock = dependencies.RoactBlock

	local expectedFields = require(LuaDiscussions.UnitTestHelpers.expectedFields)

	it("should have all and only expected fields", function()
		expectedFields(RoactBlock, {
			"verticalLayout",
			"insert",
		})
	end)
end