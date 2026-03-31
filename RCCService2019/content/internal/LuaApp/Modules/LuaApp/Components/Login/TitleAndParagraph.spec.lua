return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local TitleAndParagraph = require(Modules.LuaApp.Components.Login.TitleAndParagraph)

	local TextKeyOfLongText = "CoreScripts.PurchasePrompt.PurchaseFailed.PurchaseDisabled"
	local TextKeyOfShortText = "Feature.GamePage.LabelCancelField"

	local function wrapComponentWithMockServices(components)
		return mockServices(components, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
		})
	end

	local function findTitleComponentFromContainer(container)
		return container.Test:FindFirstChild("Title", true)
	end

	local function findParagraphComponentFromContainer(container)
		return container.Test:FindFirstChild("Paragraph", true)
	end

	it("should create and destroy without errors", function()
		local element = wrapComponentWithMockServices({
			TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
				layoutOrder = 5,
				width = 200,
				maxTitleHeight = 75,
				maxParagraphHeight = 100,
				titleTextKey = TextKeyOfShortText,
				paragraphTextKey = TextKeyOfLongText,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("Size", function()
		it("should shrink its height for title if the title is short enough", function()
			local maxTitleHeight = 100

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 400,
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfShortText,
					maxTitleHeight = maxTitleHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local titleComponent = findTitleComponentFromContainer(container)

			expect(titleComponent.AbsoluteSize.Y < maxTitleHeight).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should shrink its height for paragraph if the paragraph is short enough", function()
			local maxParagraphHeight = 100

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 400,
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfShortText,
					maxParagraphHeight = maxParagraphHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local paragraphComponent = findParagraphComponentFromContainer(container)

			expect(paragraphComponent.AbsoluteSize.Y < maxParagraphHeight).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should not exceed its specified maximum height for title if the title is too long", function()
			local maxTitleHeight = 10

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 10,
					titleTextKey = TextKeyOfLongText,
					paragraphTextKey = TextKeyOfShortText,
					maxTitleHeight = maxTitleHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local titleComponent = findTitleComponentFromContainer(container)

			expect(titleComponent.AbsoluteSize.Y == maxTitleHeight).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should not exceed its specified maximum height for paragraph if the paragraph is too long", function()
			local maxParagraphHeight = 10

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 10,
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfLongText,
					maxParagraphHeight = maxParagraphHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local paragraphComponent = findParagraphComponentFromContainer(container)

			expect(paragraphComponent.AbsoluteSize.Y == maxParagraphHeight).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should not exceed its specified width when the title is too long", function()
			local maxTitleHeight = 10
			local width = 10

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = width,
					titleTextKey = TextKeyOfLongText,
					paragraphTextKey = TextKeyOfShortText,
					maxTitleHeight = maxTitleHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local titleComponent = findTitleComponentFromContainer(container)

			expect(titleComponent.AbsoluteSize.X == width).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should not exceed its specified width when the paragraph is too long", function()
			local maxParagraphHeight = 10
			local width = 10

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = width,
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfLongText,
					maxParagraphHeight = maxParagraphHeight,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local paragraphComponent = findParagraphComponentFromContainer(container)

			expect(paragraphComponent.AbsoluteSize.Y == width).to.equal(true)

			Roact.unmount(instance)
		end)

	end)

	describe("Horizontal Alignment", function()
		it("should have the same alignment assigned to the component for both title and paragraph", function()
			local textXAlignment = Enum.TextXAlignment.Right
			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 400,
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfShortText,
					textXAlignment = textXAlignment,
				})
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")
			local titleComponent = findTitleComponentFromContainer(container)
			local paragraphComponent = findParagraphComponentFromContainer(container)

			expect(titleComponent.TextXAlignment == textXAlignment).to.equal(true)
			expect(paragraphComponent.TextXAlignment == textXAlignment).to.equal(true)

			Roact.unmount(instance)
		end)
	end)

	describe("Texts", function()
		it("should now throw error due to missing titleTextKey", function()
			local maxTitleHeight = 100

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 400,
					paragraphTextKey = TextKeyOfShortText,
					maxTitleHeight = maxTitleHeight,
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should now throw error due to missing paragraphTextKey", function()
			local maxTitleHeight = 100

			local element = wrapComponentWithMockServices({
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					width = 400,
					titleTextKey = TextKeyOfShortText,
					maxTitleHeight = maxTitleHeight,
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end