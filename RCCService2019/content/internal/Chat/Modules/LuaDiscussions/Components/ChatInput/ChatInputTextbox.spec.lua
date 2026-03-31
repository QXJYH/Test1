return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local ChatInputTextbox = require(script.Parent.ChatInputTextbox)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChatInputTextbox))

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(ChatInputTextbox, {
				LayoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("sizing", function()
		it("should consume the full width of a container excluding marginLeft and marginRight", function()
			local marginLeft = 4
			local marginRight = 6

			local mockWidth = 72

			local shouldBeThisWidth = mockWidth - (marginLeft + marginRight)
			local frame, cleanup = mountStyledFrame(Roact.createElement(ChatInputTextbox, {
				marginLeft = marginLeft,
				marginRight = marginRight,
			}))
			frame.Size = UDim2.new(0, mockWidth, 1, 0)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(shouldBeThisWidth)

			cleanup()
		end)

		it("should consume the full width of a container excluding twice the marginHeight", function()
			local marginHeight = 4
			local mockHeight = 72

			local shouldBeThisHeight = mockHeight - (marginHeight * 2)
			local frame, cleanup = mountStyledFrame(Roact.createElement(ChatInputTextbox, {
				marginHeight = marginHeight,
			}))
			frame.Size = UDim2.new(1, 0, 0, mockHeight)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.Y).to.equal(shouldBeThisHeight)

			cleanup()
		end)
	end)
end