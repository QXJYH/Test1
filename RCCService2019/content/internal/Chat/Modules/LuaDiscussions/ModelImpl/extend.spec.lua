return function()
	local extend = require(script.Parent.extend)

	it("should return a new modelDeclaration", function()
		local myModelDeclaration = extend("mockModel")

		expect(myModelDeclaration).to.be.ok()
		expect(myModelDeclaration.new).to.be.ok()
		expect(myModelDeclaration.is).to.be.ok()
	end)

	describe("modelDeclaration", function()
		describe("method new", function()
			it("should return a valid object", function()
				local myModelDeclaration = extend("mockModel")
				local myModel = myModelDeclaration.new()

				expect(myModel).to.be.ok()
			end)
		end)

		describe("method is", function()
			it("should return true when used on the new object", function()
				local myModelDeclaration = extend("mockModel")
				local myModel = myModelDeclaration.new()
				local result = myModelDeclaration.is(myModel)

				expect(result).to.equal(true)
			end)

			it("should return false for an invalid table", function()
				local myModelDeclaration = extend("mockModel")
				local myOtherModelDeclaration = extend("mockModelOther")
				local myObject = myOtherModelDeclaration.new()
				local result = myModelDeclaration.is(myObject)

				expect(result).to.equal(false)
			end)

			it("should return false for an empty table", function()
				local myModelDeclaration = extend("mockModel")
				local myObject = {}
				local result = myModelDeclaration.is(myObject)

				expect(result).to.equal(false)
			end)

			it("should return false when passed a non-table argument", function()
				local myModelDeclaration = extend("mockModel")

				local myString = "string"
				local myStringResult = myModelDeclaration.is(myString)

				expect(myStringResult).to.equal(false)

				local myNumber = 101
				local myNumberResult = myModelDeclaration.is(myNumber)

				expect(myNumberResult).to.equal(false)

				local myBoolean = false
				local myBooleanResult = myModelDeclaration.is(myBoolean)

				expect(myBooleanResult).to.equal(false)
			end)
		end)
	end)
end