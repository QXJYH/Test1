return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local Element = require(Modules.Rhodium.Element)
	local withServices = require(script.Parent.Parent.Parent.Parent.withServices)

	local Cryo = require(CorePackages.Cryo)

	local ScrollingPicker = require(Modules.LuaApp.Components.Login.ScrollingPicker)

	local WAIT_DURATION = 1.25 -- wait duration for animation to complete

	local PICKER_HEIGHT = 200
	local PICKER_ENTRY_HEIGHT = 50

	local DUMMY_ENTRIES = {
		1,
		2,
		3,
		4,
		1,
		2,
	}

	local function renderDummyEntry(entry)
		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = tostring(entry),
		})
	end

	local function wrapComponentWithMockServices(components)
		return mockServices(components, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
		})
	end

	local defaultProps = {
		size = UDim2.new(1, 0, 0, PICKER_HEIGHT),
		renderEntry = renderDummyEntry,
		entries = DUMMY_ENTRIES,
		entrySizeOnScrollingAxis = PICKER_ENTRY_HEIGHT,
		initialIndex = 1,
		onSelectedIndexChanged = function(index) end,
		oncurrentIndexChanged = function(index) end,
	}

	-- SKIP was added to disable this test because it was flaky when run on TC.
	-- LUASTARTUP-39 was filed to update the test and remove SKIP()
	SKIP()
	it("should create and destroy without errors", function()
		local element = wrapComponentWithMockServices({
			ScrollingPicker = Roact.createElement(ScrollingPicker, defaultProps)
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props were passed down", function()
		local element = wrapComponentWithMockServices({
			ScrollingPicker = Roact.createElement(ScrollingPicker)
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("initialIndex", function()
		local selectedIndex

		local function onSelectedIndexChanged(index)
			selectedIndex = index
		end

		it("should update to initialIndex after mount", function()
			local targetIndex = math.floor(#DUMMY_ENTRIES / 2)
			withServices(function(path)
				local ScrollingPicker = Element.new(path)
				expect(ScrollingPicker:waitForRbxInstance(1)).to.be.ok()
				wait(WAIT_DURATION)
				expect(selectedIndex).to.equal(targetIndex)
			end,
			ScrollingPicker,
			nil,
			Cryo.Dictionary.join(defaultProps, {
				initialIndex = targetIndex,
				onSelectedIndexChanged = onSelectedIndexChanged,
			}))
		end)
	end)

end