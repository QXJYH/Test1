local TestWithApp = require(script.Parent.Parent.TestWithApp)

return function()
	local RootPath = Rhodium.XPath.new("game.CoreGui.ExampleApp.Root")
	local ButtonPath = RootPath:cat(Rhodium.XPath.new("Button"))

	describe("Button Click", function()
		it("should update text when clicked", function()
			TestWithApp(function()
				local button = Rhodium.Element.new(ButtonPath)
				expect(button:getRbxInstance()).to.be.ok()

				button:click()
				wait()
				expect(button:getAttribute("Text")).to.equal("1")
			end)
		end)
	end)
end