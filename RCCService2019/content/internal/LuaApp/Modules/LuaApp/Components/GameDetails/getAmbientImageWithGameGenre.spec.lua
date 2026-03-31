return function()
	local getAmbientImageWithGameGenre = require(script.Parent.getAmbientImageWithGameGenre)

	it("should assert if genre is nil", function()
		expect(function()
			getAmbientImageWithGameGenre(nil)
		end).to.throw()
	end)

	it("should return an image and its size", function()
		local genre = "Town And City"
		local result = getAmbientImageWithGameGenre(genre)

		expect(type(result)).to.equal("table")
		expect(type(result.Image)).to.equal("string")
		expect(type(result.Size)).to.equal("userdata")
		expect(type(result.Size.X)).to.equal("number")
		expect(type(result.Size.Y)).to.equal("number")
	end)
end