return function()
	local AccordionViewAnimated = require(script.Parent.AccordionViewAnimated)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Constants = require(Modules.LuaApp.Constants)

	describe("AccordionViewAnimated", function()
		it("should create and destroy without errors", function()
			local element = Roact.createElement(AccordionViewAnimated, {
				items = { mediaType = 1, imageId = "1234" },
				renderItem = function() return Roact.createElement("Frame", {}) end,
				collapseButtonColor = Constants.Color.WHITE,
				fakeItemcolor = Constants.Color.WHITE,
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
