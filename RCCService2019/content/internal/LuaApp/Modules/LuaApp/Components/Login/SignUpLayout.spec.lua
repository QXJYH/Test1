return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local SignUpLayout = require(Modules.LuaApp.Components.Login.SignUpLayout)

	local TextKeyOfShortText = "Feature.GamePage.LabelCancelField"

	local function wrapComponentWithMockServices(components, initialStoreState)
		initialStoreState = initialStoreState or {}

		return mockServices(components, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = initialStoreState,
		})
	end

	local propsFormFactor
	local function dummyRenderWidget(props)
		propsFormFactor = props.formFactor
		return nil
	end

	it("should create and destroy without errors", function()
		local element = wrapComponentWithMockServices({
			SignUpLayout = Roact.createElement(SignUpLayout, {
				titleTextKey = TextKeyOfShortText,
				paragraphTextKey = TextKeyOfShortText,
				renderWidget = dummyRenderWidget,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props were passed in", function()
		local element = wrapComponentWithMockServices({
			SignUpLayout = Roact.createElement(SignUpLayout),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("renderWidget", function()
		it("should pass in formFactor to renderWidget as props when in wide view mode", function()
			propsFormFactor = FormFactor.UNKNOWN

			local element = wrapComponentWithMockServices({
				SignUpLayout = Roact.createElement(SignUpLayout, {
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfShortText,
					renderWidget = dummyRenderWidget,
				}),
			}, {
				FormFactor = FormFactor.WIDE,
			})

			local instance = Roact.mount(element)
			expect(propsFormFactor == FormFactor.WIDE).to.equal(true)
			Roact.unmount(instance)

			propsFormFactor = FormFactor.UNKNOWN
		end)

		it("should pass in formFactor to renderWidget as props when in compact view mode", function()
			propsFormFactor = FormFactor.UNKNOWN

			local element = wrapComponentWithMockServices({
				SignUpLayout = Roact.createElement(SignUpLayout, {
					titleTextKey = TextKeyOfShortText,
					paragraphTextKey = TextKeyOfShortText,
					renderWidget = dummyRenderWidget,
				}),
			}, {
				FormFactor = FormFactor.COMPACT,
			})

			local instance = Roact.mount(element)
			expect(propsFormFactor == FormFactor.COMPACT).to.equal(true)
			Roact.unmount(instance)

			propsFormFactor = FormFactor.UNKNOWN
		end)
	end)

	-- TODO Write the following when navigation is hooked up to sign up flow
	-- describe("Top Button", function()
	-- 	it("should render close button when the page SignUpLayout belongs to the first page of sign up flow", function() end)
	-- 	it("should render back button when the page SignUpLayout does not belongs to the first page of sign up flow", function() end)
	-- end)
end
