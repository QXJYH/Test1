return function()
	local ApplyNavigateUp = require(script.Parent.ApplyNavigateUp)
	local TableUtilities = require(script.Parent.Parent.TableUtilities)

	it("should return an appropriate action table", function()
		local result = ApplyNavigateUp()
		expect(TableUtilities.FieldCount(result)).to.equal(1)
		expect(result.type).to.equal(ApplyNavigateUp.name)
	end)
end
