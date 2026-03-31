return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local PaddedTextLabel = require(script.Parent.PaddedTextLabel)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(PaddedTextLabel))

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(PaddedTextLabel, {
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
		local function getAbsoluteSize(folder)
			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			return guiObject.AbsoluteSize
		end

		local function getAbsoluteSizeFromProps(props)
			local folder = Instance.new("Frame")
			local tree = Roact.createElement(PaddedTextLabel, props)
			local instance = Roact.mount(tree, folder)
			local absoluteSize = getAbsoluteSize(folder)
			Roact.unmount(instance)
			folder:Destroy()
			return absoluteSize
		end
		it("should resize to fit Text", function()
			local singleLineShortText = getAbsoluteSizeFromProps({
				Text = "!",
			})
			local singleLineLongText = getAbsoluteSizeFromProps({
				Text = "!!!!!!",
			})
			local doubleLineShortText = getAbsoluteSizeFromProps({
				Text = "!\n!"
			})
			local doubleLineLongText = getAbsoluteSizeFromProps({
				Text = "!!!!!!\n!!!!!!",
			})

			do
				-- check that none of these are equal
				expect(singleLineShortText).to.never.equal(singleLineLongText)
				expect(singleLineShortText).to.never.equal(doubleLineShortText)
				expect(singleLineShortText).to.never.equal(doubleLineLongText)

				expect(singleLineLongText).to.never.equal(doubleLineShortText)
				expect(singleLineShortText).to.never.equal(doubleLineLongText)

				expect(doubleLineShortText).to.never.equal(doubleLineLongText)
			end

			do
				-- check that widths of short/long texts are equal
				expect(singleLineShortText.X).to.equal(doubleLineShortText.X)
				expect(singleLineLongText.X).to.equal(doubleLineLongText.X)

				-- check that heights of single/double texts are equal
				expect(singleLineShortText.Y).to.equal(singleLineLongText.Y)
				expect(doubleLineShortText.Y).to.equal(doubleLineLongText.Y)
			end
		end)

		it("should resize to fit TextSize", function()
			local small = getAbsoluteSizeFromProps({
				TextSize = 6,
			})
			local medium = getAbsoluteSizeFromProps({
				TextSize = 12,
			})
			local large = getAbsoluteSizeFromProps({
				TextSize = 32,
			})

			do
				-- check that none of these are equal
				expect(small).to.never.equal(medium)
				expect(small).to.never.equal(large)
				expect(medium).to.never.equal(large)
			end
		end)

		it("should resize to fit Font", function()
			local mockText = "The quick brown fox jumped over the lazy dog..."
			local monospaced = getAbsoluteSizeFromProps({
				Font = Enum.Font.Code,
				Text = mockText,
			})
			local legacy_small = getAbsoluteSizeFromProps({
				Font = Enum.Font.Legacy,
				Text = mockText,
			})
			local normal = getAbsoluteSizeFromProps({
				Font = Enum.Font.Gotham,
				Text = mockText,
			})

			do
				-- check that none of these are equal
				expect(monospaced).to.never.equal(legacy_small)
				expect(monospaced).to.never.equal(normal)
				expect(legacy_small).to.never.equal(normal)
			end
		end)

		it("should resize to fit Padding", function()
			local noPadding = getAbsoluteSizeFromProps({})
			local verticalPadding = getAbsoluteSizeFromProps({
				PaddingBottom = 10,
				PaddingTop = 10,
			})
			local horizontalPadding = getAbsoluteSizeFromProps({
				PaddingLeft = 10,
				PaddingRight = 10,
			})
			local fullPadding = getAbsoluteSizeFromProps({
				PaddingBottom = 10,
				PaddingLeft = 10,
				PaddingRight = 10,
				PaddingTop = 10,
			})

			do
				-- check that none of these are equal
				expect(noPadding).to.never.equal(verticalPadding)
				expect(noPadding).to.never.equal(horizontalPadding)
				expect(noPadding).to.never.equal(fullPadding)

				expect(verticalPadding).to.never.equal(horizontalPadding)
				expect(verticalPadding).to.never.equal(fullPadding)

				expect(horizontalPadding).to.never.equal(fullPadding)
			end

			do
				-- check same height padding
				expect(noPadding.Y).to.equal(horizontalPadding.Y)

				-- check same width padding
				expect(noPadding.X).to.equal(verticalPadding.X)
			end
		end)
	end)

end