return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Model = dependencies.Model

	it("should have all fields", function()
		expect(Model.extend).to.be.ok()
		expect(Model.requiredProps).to.be.ok()
	end)
end