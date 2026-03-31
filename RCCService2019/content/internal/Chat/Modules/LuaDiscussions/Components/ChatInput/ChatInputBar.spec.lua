return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local ChatInputBar = require(script.Parent.ChatInputBar)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChatInputBar))

			cleanup()
		end)
	end)

	describe("sizing", function()
		it("should consume the full width of a container", function()
			local mockWidth = 72
			local frame, cleanup = mountStyledFrame(Roact.createElement(ChatInputBar))
			frame.Size = UDim2.new(0, mockWidth, 1, 0)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth)

			cleanup()
		end)
	end)
end