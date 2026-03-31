return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local AvatarThumbnail = require(script.Parent.AvatarThumbnail)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(AvatarThumbnail))

			cleanup()
		end)
	end)

	describe("props presetSize", function()
		it("passing Size36x36 should result in a width and height of 36", function()
			local targetSize = 36

			local tree = Roact.createElement(AvatarThumbnail, {
				presetSize = AvatarThumbnail.PresetSize.Size36x36,
			})
			local frame, cleanup = mountStyledFrame(tree)
			frame.Size = UDim2.new(0, 1000, 0, 1000)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(targetSize)
			expect(guiObject.AbsoluteSize.Y).to.equal(targetSize)

			cleanup()
		end)

		it("passing Size36x36 should result in a width and height of 48", function()
			local targetSize = 48

			local tree = Roact.createElement(AvatarThumbnail, {
				presetSize = AvatarThumbnail.PresetSize.Size48x48,
			})
			local frame, cleanup = mountStyledFrame(tree)
			frame.Size = UDim2.new(0, 1000, 0, 1000)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(targetSize)
			expect(guiObject.AbsoluteSize.Y).to.equal(targetSize)

			cleanup()
		end)
	end)
end