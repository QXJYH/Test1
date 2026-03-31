return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)
	local mockStyle = require(LuaDiscussions.UnitTestHelpers.mockStyle)

	local ChatBubbleContainer = require(script.Parent.ChatBubbleContainer)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChatBubbleContainer))

			cleanup()
		end)
	end)

	describe("props Children", function()
		it("should mount children", function()
			local folder, cleanup = mountStyledFrame(Roact.createElement(ChatBubbleContainer, nil, {
				child1 = Roact.createElement("Folder"),
			}))

			expect(folder:FindFirstChild("child1", true)).to.be.ok()

			cleanup()
		end)
	end)

	describe("props isIncoming", function()
		it("should change the ImageColor3 of the ancestor", function()
			local folder = Instance.new("Folder")
			local instance = Roact.mount(mockStyle(Roact.createElement(ChatBubbleContainer, {
				isIncoming = true,
			})), folder)

			local guiObject = folder:FindFirstChildWhichIsA("ImageLabel", true)
			local isIncomingImageColor = guiObject.ImageColor3

			local updatedInstance = Roact.reconcile(instance, Roact.createElement(ChatBubbleContainer, {
				isIncoming = false,
			}))
			local updatedGuiObject = folder:FindFirstChildWhichIsA("ImageLabel", true)
			local updatedIsNotIncomingImageColor = updatedGuiObject.ImageColor3

			expect(updatedIsNotIncomingImageColor).to.never.equal(isIncomingImageColor)

			Roact.unmount(updatedInstance)
			folder:Destroy()
		end)
	end)

	describe("props innerPadding", function()
		it("should update child padding element", function()
			do
				local mockPadding = 12
				local folder, cleanup = mountStyledFrame(Roact.createElement(ChatBubbleContainer, {
					innerPadding = mockPadding,
				}))

				local paddingInstance = folder:FindFirstChild("padding", true)

				expect(paddingInstance.PaddingTop.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingLeft.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingRight.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingBottom.Offset).to.equal(mockPadding)

				cleanup()
			end

			do
				local mockPadding = 32
				local folder, cleanup = mountStyledFrame(Roact.createElement(ChatBubbleContainer, {
					innerPadding = mockPadding,
				}))

				local paddingInstance = folder:FindFirstChild("padding", true)

				expect(paddingInstance.PaddingTop.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingLeft.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingRight.Offset).to.equal(mockPadding)
				expect(paddingInstance.PaddingBottom.Offset).to.equal(mockPadding)

				cleanup()
			end
		end)
	end)
end