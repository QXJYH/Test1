local UserInputService = game:GetService("UserInputService")
local TestWithApp = require(script.Parent.Parent.TestWithApp)

return function()
	local RootPath = Rhodium.XPath.new("game.CoreGui.ExampleApp.Root")
	local ScrollingFramePath = RootPath:cat(Rhodium.XPath.new("ScrollingFrame"))

	describe("ScrollingFrame", function()
		it("should move the canvas position when scrolling", function()
			TestWithApp(function()
				local scrollingFrame = Rhodium.Element.new(ScrollingFramePath)
				expect(scrollingFrame:getRbxInstance()).to.be.ok()

				wait(0.5)
				if UserInputService.MouseEnabled then
					Rhodium.VirtualInput.mouseWheel(scrollingFrame:getCenter(), 2)
				elseif UserInputService.TouchEnabled then
					Rhodium.VirtualInput.swipe(scrollingFrame:getCenter(),
						scrollingFrame:getCenter() + Vector2.new(0, -100), 0.25, false)
				end

				wait(0.5)
				local hasMoved = scrollingFrame:getAttribute("CanvasPosition").Y > 0
				expect(hasMoved).to.equal(true)
			end)
		end)
	end)
end