return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)
	local mockStyle = require(LuaDiscussions.UnitTestHelpers.mockStyle)

	local NavigateBackButton = require(script.Parent.NavigateBackButton)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(NavigateBackButton))

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(NavigateBackButton, {
				LayoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("props fullExtents", function()
		it("should remain a 1:1 aspect ratio", function()
			local frame = Instance.new("Frame")

			local mockExtents1 = 72
			local mockExtents2 = 128
			local mockExtents3 = 32

			local tree1 = mockStyle(Roact.createElement(NavigateBackButton, {
				fullExtents = mockExtents1,
			}))
			local tree2 = mockStyle(Roact.createElement(NavigateBackButton, {
				fullExtents = mockExtents2,
			}))
			local tree3 = mockStyle(Roact.createElement(NavigateBackButton, {
				fullExtents = mockExtents3,
			}))

			local instance1 = Roact.mount(tree1, frame)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject1.AbsoluteSize.X).to.equal(mockExtents1)
			expect(guiObject1.AbsoluteSize.X).to.equal(guiObject1.AbsoluteSize.Y)

			local instance2 = Roact.reconcile(instance1, tree2)
			local guiObject2 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject2.AbsoluteSize.X).to.equal(mockExtents2)
			expect(guiObject2.AbsoluteSize.X).to.equal(guiObject2.AbsoluteSize.Y)

			local instance3 = Roact.reconcile(instance2, tree3)
			local guiObject3 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject3.AbsoluteSize.X).to.equal(mockExtents3)
			expect(guiObject3.AbsoluteSize.X).to.equal(guiObject3.AbsoluteSize.Y)

			Roact.unmount(instance3)
			frame:Destroy()
		end)
	end)
end