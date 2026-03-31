return function()
	local CoreGui = game:GetService("CoreGui")
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = CoreGui.RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local ScreenGuiWithBlurControl = require(Modules.LuaApp.Components.ScreenGuiWithBlurControl)

	local function mockStore(hasBlur, blurDisplayOrder)
		local testDetails = hasBlur and {
			["AppRouter"] = blurDisplayOrder
		} or {}

		return MockStore.new({
			ScreenGuiBlur = {
				hasBlur = hasBlur,
				blurDisplayOrder = blurDisplayOrder,
				details = testDetails,
			},
		})
	end

	local function testScreenGuiWithBlur(hasBlur, blurDisplayOrder, displayOrder, expectedOnTopOfCoreBlur)
		local store = mockStore(hasBlur, blurDisplayOrder)

		local element = mockServices({
			ScreenGuiWithBlurControl = Roact.createElement(ScreenGuiWithBlurControl, {
				DisplayOrder = displayOrder,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "ScreenGui")

		local screenGui = container.ScreenGui
		expect(screenGui.OnTopOfCoreBlur).to.equal(expectedOnTopOfCoreBlur)

		Roact.unmount(instance)
		store:destruct()
	end

	it("should set OnTopOfCoreBlur to false when hasBlur == false", function()
		testScreenGuiWithBlur(false, 0, 0, false)
	end)

	it("should set OnTopOfCoreBlur to false when hasBlur == true but displayOrder < blurDisplayOrder", function()
		testScreenGuiWithBlur(true, 5, 2, false)
	end)

	it("should set OnTopOfCoreBlur to true when hasBlur == true and displayOrder >= blurDisplayOrder", function()
		testScreenGuiWithBlur(true, 5, 5, true)
		testScreenGuiWithBlur(true, 5, 10, true)
	end)
end