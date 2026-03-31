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

	-- SKIP was added to disable this test because it was flaky when run on TC.
	-- LUASTARTUP-39 was filed to update the test and remove SKIP()
	SKIP()
	local defaultProps = {
		size = UDim2.new(1, 0, 0, PICKER_HEIGHT),
		renderEntry = renderDummyEntry,
		entries = DUMMY_ENTRIES,
		entrySizeOnScrollingAxis = PICKER_ENTRY_HEIGHT,
		initialIndex = 1,
		onSelectedIndexChanged = function(index) end,
		oncurrentIndexChanged = function(index) end,
	}

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

	describe("on index change", function()
		local currentIndicesLogged = {}
		local numberOfTimesOnCurrentIndexChangeWasCalled = 0

		local selectedIndex
		local numberOfTimesOnSelectedIndexChangeWasCalled = 0

		local function initializeTestParameters()
			currentIndicesLogged = {}
			numberOfTimesOnCurrentIndexChangeWasCalled = 0

			selectedIndex = nil
			numberOfTimesOnSelectedIndexChangeWasCalled = 0
		end

		local function onCurrentIndexChanged(index)
			currentIndicesLogged[#currentIndicesLogged + 1] = index
			numberOfTimesOnCurrentIndexChangeWasCalled = numberOfTimesOnCurrentIndexChangeWasCalled + 1
		end

		local function onSelectedIndexChanged(index)
			selectedIndex = index
			numberOfTimesOnSelectedIndexChangeWasCalled = numberOfTimesOnSelectedIndexChangeWasCalled + 1
		end

		it("should call callback function onSelectedIndexChanged after ScrollingPicker has reached its target index", function()
			withServices(function(path)
				initializeTestParameters()
				local ScrollingPicker = Element.new(path)
				expect(ScrollingPicker:waitForRbxInstance(1)).to.be.ok()
				wait(WAIT_DURATION)
				expect(selectedIndex).to.equal(#DUMMY_ENTRIES)
				expect(numberOfTimesOnSelectedIndexChangeWasCalled).to.equal(1)
			end,
			ScrollingPicker,
			nil,
			Cryo.Dictionary.join(defaultProps, {
				initialIndex = #DUMMY_ENTRIES,
				onCurrentIndexChanged = onCurrentIndexChanged,
				onSelectedIndexChanged = onSelectedIndexChanged,
			}))
		end)

		it("should call callback function onCurrentIndexChanged whenever current index changes until ScrollingPicker has reached its target index", function()
			withServices(function(path)
				initializeTestParameters()
				local ScrollingPicker = Element.new(path)
				expect(ScrollingPicker:waitForRbxInstance(1)).to.be.ok()
				wait(WAIT_DURATION)
				expect(#currentIndicesLogged).to.equal(#DUMMY_ENTRIES - 1) -- -1 to exclude the first entry, which should not count since current index did not change.
				for key, loggedCurrentIndex in pairs(currentIndicesLogged) do
					expect(loggedCurrentIndex).to.equal(key + 1)
				end
				expect(numberOfTimesOnCurrentIndexChangeWasCalled).to.equal(#DUMMY_ENTRIES - 1)
			end,
			ScrollingPicker,
			nil,
			Cryo.Dictionary.join(defaultProps, {
				initialIndex = #DUMMY_ENTRIES,
				onCurrentIndexChanged = onCurrentIndexChanged,
				onSelectedIndexChanged = onSelectedIndexChanged,
			}))
		end)
	end)

end