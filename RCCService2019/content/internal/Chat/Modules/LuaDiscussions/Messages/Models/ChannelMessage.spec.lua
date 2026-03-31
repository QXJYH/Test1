return function()
	local ChannelMessage = require(script.Parent.ChannelMessage)

	describe("method fromProps", function()
		it("should return a valid object", function()
			local myObject = ChannelMessage.fromProps({
				chunks = {},
				id = "id",
				created = "created",
			})
			local result = ChannelMessage.is(myObject)

			expect(myObject).to.be.ok()
			expect(result).to.equal(true)
		end)
	end)

	describe("method new", function()
		it("should return a valid object", function()
			local myObject = ChannelMessage.new()

			expect(myObject).to.be.ok()
		end)
	end)

	describe("method is", function()
		it("should return true for a created ChannelMessage", function()
			local myObject = ChannelMessage.new()
			local result = ChannelMessage.is(myObject)

			expect(result).to.equal(true)
		end)

		it("should return false for an invalid ChannelMessage", function()
			local myObject = {}
			local result = ChannelMessage.is(myObject)

			expect(result).to.equal(false)
		end)

		it("should return false when passed a non-table argument", function()
			local myString = "string"
			local myStringResult = ChannelMessage.is(myString)

			expect(myStringResult).to.equal(false)

			local myNumber = 101
			local myNumberResult = ChannelMessage.is(myNumber)

			expect(myNumberResult).to.equal(false)

			local myBoolean = false
			local myBooleanResult = ChannelMessage.is(myBoolean)

			expect(myBooleanResult).to.equal(false)
		end)
	end)
end