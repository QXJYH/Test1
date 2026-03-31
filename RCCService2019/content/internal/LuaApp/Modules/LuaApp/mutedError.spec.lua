return function()
	local mutedError = require(script.Parent.mutedError)

	it("should throw the errorMessage we passed in if it's a string", function()
		local testErrorMessage = "testError"
		local result, err = pcall(function()
			mutedError(testErrorMessage)
		end)

		expect(result).to.equal(false)
		expect(string.match(err, testErrorMessage) ~= nil).to.equal(true)
	end)

	it("should try to convert errorMessage to a string if it's not and throw it", function()
		local testErrorMessage = 123
		local result, err = pcall(function()
			mutedError(testErrorMessage)
		end)

		expect(result).to.equal(false)
		expect(string.match(err, testErrorMessage) ~= nil).to.equal(true)
	end)

	it("should throw a generic error if errorMessage cannot be converted to string", function()
		local testErrorMessage = {}
		setmetatable(testErrorMessage, {
			__tostring = function() error("no string") end,
		})

		local result, err = pcall(function()
			mutedError(testErrorMessage)
		end)

		expect(result).to.equal(false)
		expect(string.match(err, "mutedError") ~= nil).to.equal(true)
	end)
end