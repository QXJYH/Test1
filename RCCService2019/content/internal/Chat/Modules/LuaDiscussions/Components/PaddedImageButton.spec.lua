return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local PaddedImageButton = require(script.Parent.PaddedImageButton)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(PaddedImageButton))

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(PaddedImageButton, {
				LayoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("props Size", function()
		it("should set the bounding size of the ancestor guiObject", function()
			local frame = Instance.new("Frame")

			local mockSize1 = UDim2.new(UDim.new(0, 100), UDim.new(0, 100))
			local mockSize2 = UDim2.new(UDim.new(0, 64), UDim.new(0, 800))
			local mockSize3 = UDim2.new(UDim.new(0, 400), UDim.new(0, 20))

			local tree1 = Roact.createElement(PaddedImageButton, {
				Size = mockSize1,
			})
			local tree2 = Roact.createElement(PaddedImageButton, {
				Size = mockSize2,
			})
			local tree3 = Roact.createElement(PaddedImageButton, {
				Size = mockSize3,
			})

			local instance1 = Roact.mount(tree1, frame)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject1.Size).to.equal(mockSize1)

			local instance2 = Roact.reconcile(instance1, tree2)
			local guiObject2 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject2.Size).to.equal(mockSize2)

			local instance3 = Roact.reconcile(instance2, tree3)
			local guiObject3 = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject3.Size).to.equal(mockSize3)

			Roact.unmount(instance3)
			frame:Destroy()
		end)
	end)

	describe("props PaddingWidth", function()
		it("should set the PaddingLeft and PaddingRight properties of the child padding element", function()
			local mockPaddingWidth = 16
			local tree = Roact.createElement(PaddedImageButton, {
				paddingWidth = mockPaddingWidth,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChild("padding", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.PaddingLeft.Offset).to.equal(mockPaddingWidth)
			expect(guiObject.PaddingRight.Offset).to.equal(mockPaddingWidth)

			cleanup()
		end)
	end)

	describe("props PaddingHeight", function()
		it("should set the PaddingTop and PaddingBottom properties of the child padding element", function()
			local mockPaddingHeight = 32
			local tree = Roact.createElement(PaddedImageButton, {
				paddingHeight = mockPaddingHeight,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChild("padding", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.PaddingTop.Offset).to.equal(mockPaddingHeight)
			expect(guiObject.PaddingBottom.Offset).to.equal(mockPaddingHeight)

			cleanup()
		end)
	end)

	describe("props Image", function()
		it("should set the Image of the child imageButton element", function()
			local mockImage = "rbxasset://path/to/mock/image.png"
			local tree = Roact.createElement(PaddedImageButton, {
				Image = mockImage,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local imageButtonInstance = folder:FindFirstChild("imageButton", true)
			expect(imageButtonInstance).to.be.ok()
			expect(imageButtonInstance.Image).to.equal(mockImage)

			cleanup()
		end)
	end)
end