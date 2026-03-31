return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local PlainText = require(script.Parent.PlainText)

	local function createPlainTextChunk(message)
		return {
			message = message,
		}
	end

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(PlainText))

			cleanup()
		end)
	end)

	describe("prop messageChunk", function()
		it("two PlainText bubbles with differing message chunks should have differing sizes", function()
			local tree1 = Roact.createElement(PlainText, {
				messageChunk = createPlainTextChunk("!")
			})
			local frame, cleanup = mountStyledFrame(tree1)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)
			local treeAbsoluteSize1 = guiObject1.AbsoluteSize

			cleanup()

			local tree2 = Roact.createElement(PlainText, {
				messageChunk = createPlainTextChunk("!!!")
			})
			local frame2, cleanup2 = mountStyledFrame(tree2)
			local guiObject2 = frame2:FindFirstChildWhichIsA("GuiObject", true)
			local tree2AbsoluteSize = guiObject2.AbsoluteSize

			expect(treeAbsoluteSize1).to.never.equal(tree2AbsoluteSize)

			cleanup2()
		end)

		it("should never opt to truncate", function()
			local mockText = "Sample message. Don't read me."
			local tree1 = Roact.createElement(PlainText, {
				messageChunk = createPlainTextChunk(mockText),
				maxWidth = 20,
			})
			local frame, cleanup = mountStyledFrame(tree1)

			local textLabelInstance = frame:FindFirstChildWhichIsA("TextLabel", true)
			expect(textLabelInstance.Text).to.equal(mockText)

			cleanup()
		end)
	end)

	describe("prop maxWidth", function()
		it("PlainText bubble width should respect maxWidth", function()
			local mockMaxWidth = 24
			local function createPlainTextTreeWithMessage(message)
				return Roact.createElement(PlainText, {
					messageChunk = createPlainTextChunk(message),
					maxWidth = mockMaxWidth,
				})
			end

			local oneHundredBangs = string.rep("!", 100)
			local fiveHundredBangs = string.rep("!", 500)

			local tree1 = createPlainTextTreeWithMessage(oneHundredBangs)
			local frame, cleanup = mountStyledFrame(tree1)
			local guiObject1 = frame:FindFirstChildWhichIsA("GuiObject", true)

			local treeAbsoluteSize1 = guiObject1.AbsoluteSize
			expect(treeAbsoluteSize1.X <= mockMaxWidth).to.equal(true)

			cleanup()

			local tree2 = createPlainTextTreeWithMessage(fiveHundredBangs)
			local frame2, cleanup2 = mountStyledFrame(tree2)
			local guiObject2 = frame2:FindFirstChildWhichIsA("GuiObject", true)

			local tree2AbsoluteSize = guiObject2.AbsoluteSize
			expect(tree2AbsoluteSize.X <= mockMaxWidth).to.equal(true)

			cleanup2()
		end)
	end)
end