return function()
	local ApplySetNavigationLocked = require(script.Parent.ApplySetNavigationLocked)
	local TableUtilities = require(script.Parent.Parent.TableUtilities)

	it("should throw for non-boolean locked arg", function()
		expect(function()
			ApplySetNavigationLocked()
		end).to.throw()

		expect(function()
			ApplySetNavigationLocked(nil)
		end).to.throw()

		expect(function()
			ApplySetNavigationLocked("")
		end).to.throw()

		expect(function()
			ApplySetNavigationLocked({})
		end).to.throw()
	end)

	it("should return matching boolean for locked arg", function()
		local result = ApplySetNavigationLocked(true)
		expect(result.locked).to.equal(true)
		expect(result.type).to.equal(ApplySetNavigationLocked.name)
		expect(TableUtilities.FieldCount(result)).to.equal(2)

		local result2 = ApplySetNavigationLocked(false)
		expect(result2.locked).to.equal(false)
		expect(result.type).to.equal(ApplySetNavigationLocked.name)
		expect(TableUtilities.FieldCount(result2)).to.equal(2)
	end)
end
