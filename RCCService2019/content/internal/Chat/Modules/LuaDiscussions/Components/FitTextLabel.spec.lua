return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local FitTextLabel = require(script.Parent.FitTextLabel)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(FitTextLabel))

			cleanup()
		end)
	end)

	describe("sizing", function()
		it("should update sizing from Text changes", function()
			local function createLabelWithText(text)
				return Roact.createElement(FitTextLabel, {
					Text = text,
				})
			end
			local tree1 = createLabelWithText("!")
			local tree2 = createLabelWithText("!!!")

			local frame = Instance.new("Frame")
			local instance = Roact.mount(tree1, frame)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize1 = guiObject1.AbsoluteSize
			Roact.reconcile(instance, tree2)
			local guiObject2 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize2 = guiObject2.AbsoluteSize

			expect(treeAbsoluteSize1).to.never.equal(treeAbsoluteSize2)

			Roact.unmount(instance)
			frame:Destroy()
		end)

		it("should update sizing from Font changes", function()
			local function createLabelWithFont(font)
				return Roact.createElement(FitTextLabel, {
					Text = "Hello there. How are you doing?",
					Font = font,
				})
			end
			local tree1 = createLabelWithFont(Enum.Font.Code)
			local tree2 = createLabelWithFont(Enum.Font.Legacy)

			local frame = Instance.new("Frame")
			local instance = Roact.mount(tree1, frame)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize1 = guiObject1.AbsoluteSize
			Roact.reconcile(instance, tree2)
			local guiObject2 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize2 = guiObject2.AbsoluteSize

			expect(treeAbsoluteSize1).to.never.equal(treeAbsoluteSize2)

			Roact.unmount(instance)
			frame:Destroy()
		end)

		it("should update sizing from TextSize changes", function()
			local function createLabelWithTextSize(textSize)
				return Roact.createElement(FitTextLabel, {
					Text = "!",
					TextSize = textSize,
				})
			end
			local tree1 = createLabelWithTextSize(12)
			local tree2 = createLabelWithTextSize(100)

			local frame = Instance.new("Frame")
			local instance = Roact.mount(tree1, frame)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize1 = guiObject1.AbsoluteSize
			Roact.reconcile(instance, tree2)
			local guiObject2 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize2 = guiObject2.AbsoluteSize

			expect(treeAbsoluteSize1).to.never.equal(treeAbsoluteSize2)

			Roact.unmount(instance)
			frame:Destroy()
		end)
	end)

	describe("props maxWidth", function()
		it("should never allow ancestor guiObject to exceed maxWidth", function()
			local mockMaxWidth = 24
			local function createFitTextLabelWithText(text)
				return Roact.createElement(FitTextLabel, {
					Text = text,
					maxWidth = mockMaxWidth,
				})
			end

			local oneHundredBangs = string.rep("!", 100)
			local fiveHundredBangs = string.rep("!", 500)

			local tree1 = createFitTextLabelWithText(oneHundredBangs)
			local frame, cleanup = mountStyledFrame(tree1)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)

			local treeAbsoluteSize1 = guiObject1.AbsoluteSize

			expect(treeAbsoluteSize1.X <= mockMaxWidth).to.equal(true)

			cleanup()

			local tree2 = createFitTextLabelWithText(fiveHundredBangs)
			local frame2, cleanup2 = mountStyledFrame(tree2)
			local guiObject2 = frame2:FindFirstChildWhichIsA("GuiObject", true)

			local tree2AbsoluteSize = guiObject2.AbsoluteSize

			expect(tree2AbsoluteSize.X <= mockMaxWidth).to.equal(true)

			cleanup2()
		end)
	end)

	describe("props Text", function()
		it("should display given Text", function()
			local mockText = "foobar"
			local tree = Roact.createElement(FitTextLabel, {
				Text = mockText,
			})

			local folder, cleanup = mountStyledFrame(tree)

			local textLabelInstance = folder:FindFirstChildOfClass("TextLabel", true)

			expect(textLabelInstance.Text).to.equal(mockText)

			cleanup()
		end)
	end)

end