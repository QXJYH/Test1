return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact

	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local ChannelTitle = require(script.Parent.ChannelTitle)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChannelTitle))
			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(ChannelTitle, {
				LayoutOrder = mockLayoutOrder,
			})
			local frame, cleanup = mountStyledFrame(tree)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("prop channelName", function()
		it("should display a pound sign followed by channelName", function()
			local tree = Roact.createElement(ChannelTitle, {
				channelName = "testing",
			})
			local frame, cleanup = mountStyledFrame(tree)

			local textLabel = frame:FindFirstChildOfClass("TextLabel", true)
			expect(textLabel).to.be.ok()
			expect(textLabel.Text).to.equal("#testing")

			cleanup()
		end)
	end)
end