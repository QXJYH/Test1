return function()
	local LocalizationConsumer = require(script.Parent.LocalizationConsumer)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Localization = require(Modules.LuaApp.Localization)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local root = mockServices({
			element = Roact.createElement(LocalizationConsumer, {
				stringsToBeLocalized = {},
				render = function() end,
			}),
		}, {
			includeLocalizationProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should throw if not under LocalizationProvider", function()
		local root = mockServices({
			element = Roact.createElement(LocalizationConsumer, {
				stringsToBeLocalized = {},
				render = function() end,
			}),
		}, {
			includeLocalizationProvider = false,
		})

		expect(function()
			Roact.mount(root)
		end).to.throw()
	end)

	it("should throw if render is not a function", function()
		local createRoot = function(render)
			return mockServices({
				element = Roact.createElement(LocalizationConsumer, {
					stringsToBeLocalized = {},
					render = render,
				}),
			}, {
				includeLocalizationProvider = true,
			})
		end

		expect(function()
			Roact.mount(createRoot(nil))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(1))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(""))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(true))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot({}))
		end).to.throw()
	end)

	it("should throw if stringsToBeLocalized is not a table", function()
		local createRoot = function(stringsToBeLocalized)
			return mockServices({
				element = Roact.createElement(LocalizationConsumer, {
					stringsToBeLocalized = stringsToBeLocalized,
					render = function() end,
				}),
			}, {
				includeLocalizationProvider = true,
			})
		end

		expect(function()
			Roact.mount(createRoot(nil))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(1))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(""))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(true))
		end).to.throw()

		expect(function()
			Roact.mount(createRoot(function() end))
		end).to.throw()
	end)

	it("should get correct localized strings", function()
		local localization = Localization.mock()
		local stringKey = "CommonUI.Features.Label.Catalog"
		local localizedString = localization:Format(stringKey)

		local root = mockServices({
			element = Roact.createElement(LocalizationConsumer, {
				stringsToBeLocalized = {
					text = stringKey,
				},
				render = function(localized)
					expect(localized.text).to.equal(localizedString)
					return Roact.createElement("TextLabel", {
						Text = localized.text,
					})
				end,
			}),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(root, container, "textLabel")
		expect(container.textLabel.Text).to.equal(localizedString)
		Roact.unmount(instance)
	end)

	it("should throw if there's no string key exists", function()
		local localization = Localization.mock()

		local root = mockServices({
			element = Roact.createElement(LocalizationConsumer, {
				stringsToBeLocalized = {
					text = "test",
				},
				render = function() end,
			}),
		}, {
			includeLocalizationProvider = true,
			localization = localization,
		})

		expect(function()
			Roact.mount(root)
		end).to.throw()
	end)
end