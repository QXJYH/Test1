return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local GradientImage = require(script.Parent.GradientImage)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(GradientImage))

			cleanup()
		end)
	end)

	describe("sizing", function()
		it("should fill its parent container", function()
			local mockWidth = 182
			local mockHeight = 374

			local frame, cleanup = mountStyledFrame(Roact.createElement(GradientImage))
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth)
			expect(guiObject.AbsoluteSize.Y).to.equal(mockHeight)

			cleanup()
		end)
	end)
end