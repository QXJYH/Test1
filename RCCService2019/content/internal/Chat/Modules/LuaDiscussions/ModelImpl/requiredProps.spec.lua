return function()
	local requiredProps = require(script.Parent.requiredProps)

	describe("model implementation impact", function()
		it("should return the same implemention it was given", function()
			local modelImpl = {}
			local result = requiredProps(modelImpl, {})

			expect(result).to.equal(modelImpl)
		end)

		it("should create a fromProps function within the implementation it was given", function()
			local modelImpl = {}
			local result = requiredProps(modelImpl, {})

			expect(result.fromProps).to.be.ok()
		end)
	end)

	describe("prop assertions", function()
		local function getModelImpl()
			return {
				new = function()
					return {}
				end,
			}
		end

		describe("missing declarations", function()
			it("should return a valid object with no required props", function()
				local model = requiredProps(getModelImpl(), {})
				local result = model.fromProps({})

				expect(result).to.be.ok()
			end)

			it("should throw if required props list is missing", function()
				expect(function()
					requiredProps(getModelImpl(), nil)
				end).to.throw()
			end)

			it("should throw if fromProps props are missing", function()
				local model = requiredProps(getModelImpl(), {})

				expect(function()
					model.fromProps(nil)
				end).to.throw()
			end)

			it("should throw if required prop is missing", function()
				local model = requiredProps(getModelImpl(), {
					id = "string"
				})

				expect(function()
					model.fromProps({})
				end).to.throw()
			end)
		end)

		describe("type checking", function()
			it("should return a valid object if all props are present", function()
				local model = requiredProps(getModelImpl(), {
					foo = "string",
					bar = "string",
				})
				local result = model.fromProps({
					foo = "hello",
					bar = "world",
				})

				expect(result).to.be.ok()
			end)

			it("should throw if given mismatching prop type", function()
				local model = requiredProps(getModelImpl(), {
					foo = "string",
					bar = "string",
				})

				expect(function()
					model.fromProps({
						foo = 1001,
						bar = "world",
					})
				end).to.throw()
			end)
		end)
	end)
end