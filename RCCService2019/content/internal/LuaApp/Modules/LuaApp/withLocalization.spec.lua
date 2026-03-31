return function()
	local withLocalization = require(script.Parent.withLocalization)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Localization = require(Modules.LuaApp.Localization)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testTextLabel = function(textKey)
		return withLocalization({
			text = textKey
		})(function(localized)
			return Roact.createElement("TextLabel", {
				Text = localized.text,
			})
		end)
	end

	it("should create and destroy without errors", function()
		local localization = Localization.mock()
		local stringKey = "CommonUI.Features.Label.Catalog"

		local element = mockServices({
			textLabel = testTextLabel(stringKey),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "textLabel")
		expect(container.textLabel.Text).to.equal(localization:Format(stringKey))
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when stringsToBeLocalized changes", function()
		local localization = Localization.mock()
		local stringKey1 = "CommonUI.Features.Label.Avatar"
		local stringKey2 = "CommonUI.Features.Label.Catalog"

		local element = mockServices({
			textLabel = testTextLabel(stringKey1),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "textLabel")
		expect(container.textLabel.Text).to.equal(localization:Format(stringKey1))

		Roact.reconcile(instance, mockServices({
			textLabel = testTextLabel(stringKey2),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		}))
		expect(container.textLabel.Text).to.equal(localization:Format(stringKey2))

		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when locale changes", function()
		local localization = Localization.mock()

		local stringKey = "CommonUI.Features.Label.Avatar"

		local element = mockServices({
			textLabel = testTextLabel(stringKey),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "textLabel")
		expect(container.textLabel.Text).to.equal(localization:Format(stringKey))

		localization:SetLocale("zh-cn")

		Roact.reconcile(instance, mockServices({
			textLabel = testTextLabel(stringKey),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		}))
		expect(container.textLabel.Text).to.equal(localization:Format(stringKey))
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with > 1 entries to be localized", function()
		local localization = Localization.mock()

		local stringKey1 = "CommonUI.Features.Label.Profile"
		local stringKey2 = { "CommonUI.Features.Label.VersionWithNumber", versionNumber = "1.0" }

		local testFrame = withLocalization({
			text1 = stringKey1,
			text2 = stringKey2,
		})(function(localized)
			return Roact.createElement("Frame", nil, {
				textLabel1 = Roact.createElement("TextLabel", {
					Text = localized.text1,
				}),
				textLabel2 = Roact.createElement("TextLabel", {
					Text = localized.text2,
				}),
			})
		end)

		local element = mockServices({
			testFrame = testFrame,
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "testFrame")
		expect(container.testFrame.textLabel1.Text).to.equal(localization:Format(stringKey1))
		expect(container.testFrame.textLabel2.Text).to.equal(localization:Format(stringKey2[1], "1.0"))
		Roact.unmount(instance)
	end)
end