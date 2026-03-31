return function()
	local MakeNetworkActions = require(script.Parent.MakeNetworkActions)

	describe("GIVEN a script", function()
		local myScript = Instance.new("ModuleScript")
		local result = MakeNetworkActions(myScript)

		it("SHOULD return an object with a success field and failed field", function()
			expect(result.Succeeded).to.be.ok()
			expect(result.Failed).to.be.ok()
		end)
	end)
end