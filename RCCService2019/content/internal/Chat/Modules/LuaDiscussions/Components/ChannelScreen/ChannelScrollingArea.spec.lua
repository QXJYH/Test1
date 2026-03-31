return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)
	local mockStyle = require(LuaDiscussions.UnitTestHelpers.mockStyle)

	local ChannelScrollingArea = require(script.Parent.ChannelScrollingArea)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChannelScrollingArea))

			cleanup()
		end)
	end)

	describe("sizing", function()
		it("should fill its parent container", function()
			local mockWidth = 182
			local mockHeight = 374

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)
			local _, cleanup = mountStyledFrame(Roact.createElement(ChannelScrollingArea), frame)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth)
			expect(guiObject.AbsoluteSize.Y).to.equal(mockHeight)

			cleanup()
		end)
	end)

	describe("prop channelMessages", function()
		local globalMessageId = 0
		local function createMessage(text)
			globalMessageId = globalMessageId + 1
			local messageId = "id-" .. globalMessageId

			local channelMessage = {
				chunks = {
					type = "PlainText",
					message = text,
				},
				id = messageId,
				sent = "whenever",
			}

			return channelMessage
		end

		local zeroMessages = {}
		local oneMessage = {
			createMessage("hello"),
		}
		local threeMessages = {
			createMessage("hello"),
			createMessage("world"),
			createMessage("!!!!!"),
		}

		local function createTreeFromMessages(channelMessages)
			return Roact.createElement(ChannelScrollingArea, {
				channelMessages = channelMessages,
			})
		end

		it("should render channelMessages as they are given", function()
			local function createAndCountChildren(channelMessages)
				local tree = Roact.createElement(ChannelScrollingArea, {
					channelMessages = channelMessages,
				})
				local folder, cleanup = mountStyledFrame(tree)
				local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
				local childrenCount = #guiObject:GetChildren()

				cleanup()
				return childrenCount
			end

			local zeroMessageChildrenCount = createAndCountChildren(zeroMessages)
			local oneMessageChildrenCount = createAndCountChildren(oneMessage)
			local threeMessageChildrenCount = createAndCountChildren(threeMessages)

			-- If this expectation is not met, it's likely ChannelScrollingArea is
			-- not rendering any children at all.
			expect(
				zeroMessageChildrenCount == oneMessageChildrenCount
				and oneMessageChildrenCount == threeMessageChildrenCount
			).to.never.equal(true)

			expect(type(zeroMessageChildrenCount)).to.equal("number")
			expect(type(oneMessageChildrenCount)).to.equal("number")
			expect(type(threeMessageChildrenCount)).to.equal("number")
			expect(zeroMessageChildrenCount).to.never.equal(oneMessageChildrenCount)
			expect(zeroMessageChildrenCount).to.never.equal(threeMessageChildrenCount)
			expect(oneMessageChildrenCount).to.never.equal(threeMessageChildrenCount)
		end)

		it("should have a different CanvasSize for different numbers of elements", function()
			local function createAndGetCanvasHeight(channelMessages)
				local tree = createTreeFromMessages(channelMessages)
				local folder, cleanup = mountStyledFrame(tree)
				local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
				local canvasSizeHeight = guiObject.CanvasSize.Y.Offset

				cleanup()
				return canvasSizeHeight
			end

			local zeroMessageCanvasSize = createAndGetCanvasHeight(zeroMessages)
			local oneMessageCanvasSize = createAndGetCanvasHeight(oneMessage)
			local threeMessageCanvasSize = createAndGetCanvasHeight(threeMessages)

			expect(type(zeroMessageCanvasSize)).to.equal("number")
			expect(type(oneMessageCanvasSize)).to.equal("number")
			expect(type(threeMessageCanvasSize)).to.equal("number")
			expect(zeroMessageCanvasSize).to.never.equal(oneMessageCanvasSize)
			expect(zeroMessageCanvasSize).to.never.equal(threeMessageCanvasSize)
			expect(oneMessageCanvasSize).to.never.equal(threeMessageCanvasSize)
		end)

		it("should change its CanvasSize when updated", function()
			local function getCanvasHeight(folder)
				local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
				return guiObject.CanvasSize.Y.Offset
			end

			local tree1 = mockStyle(createTreeFromMessages(zeroMessages))
			local tree2 = mockStyle(createTreeFromMessages(oneMessage))
			local tree3 = mockStyle(createTreeFromMessages(threeMessages))

			local folder = Instance.new("Folder")

			local instance = Roact.mount(tree1, folder)
			local zeroCanvasSize = getCanvasHeight(folder)
			Roact.reconcile(instance, tree2)
			local oneCanvasSize = getCanvasHeight(folder)
			Roact.reconcile(instance, tree3)
			local threeCanvasSize = getCanvasHeight(folder)

			expect(type(zeroCanvasSize)).to.equal("number")
			expect(type(oneCanvasSize)).to.equal("number")
			expect(type(threeCanvasSize)).to.equal("number")
			expect(zeroCanvasSize).to.never.equal(oneCanvasSize)
			expect(zeroCanvasSize).to.never.equal(threeCanvasSize)
			expect(oneCanvasSize).to.never.equal(threeCanvasSize)
		end)
	end)
end