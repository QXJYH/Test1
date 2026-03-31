return function()
	local mockServices = require(script.Parent.mockServices)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local StyleConstants = require(CorePackages.AppTempCommon.LuaApp.Style.Constants)
	local RoactServices = require(Modules.LuaApp.RoactServices)

	it("should construct a Roact element that contains an initialized RoactServices", function()
		local testComponent = function() end
		local element = mockServices({
			tc = Roact.createElement(testComponent)
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should throw if no components are provided to render", function()
		expect(function()
			local element = mockServices()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	-- Walk the tree of providers to find the one with matching name
	local function findProviderInDescendants(root, providerName)
		local current = root
		while (current ~= nil) do
			local children = current.props[Roact.Children]

			if not children then
				return nil
			end

			local key, child = next(children)
			local after = next(children, key)

			if child == nil or after ~= nil then
				return nil
			end

			if key == providerName then
				return child
			else
				current = child
			end
		end
		return nil
	end

	describe("should accept a table of additional args...", function()
		describe("extraArgs.includeStoreProvider", function()
			it("should expect a boolean", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						includeStoreProvider = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(false)
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue({})
				end).to.throw()
			end)

			it("should add a StoreProvider into the returned Roact element", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeStoreProvider = true
				})

				expect(findProviderInDescendants(element, "StoreProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.store", function()
			it("should do nothing if extraArgs.includeStoreProvider is false or not included", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					store = {}
				})

				expect(findProviderInDescendants(element, "StoreProvider")).to.equal(nil)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)

			it("should expect a table", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						store = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue({})
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue(false)
				end).to.throw()
			end)

			it("should initialize the Rodux Store", function()
				local testStore = {
					LocalUserId = "hello world"
				}

				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeStoreProvider = true,
					store = testStore
				})

				local storeProvider = findProviderInDescendants(element, "StoreProvider")
				expect(storeProvider).to.be.ok()

				local elementStore = storeProvider.props["store"]
				expect(getmetatable(elementStore)).to.equal(Rodux.Store)
				expect(elementStore:getState().LocalUserId).to.equal("hello world")

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.includeThemeProvider", function()
			it("should expect a boolean", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						includeThemeProvider = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(false)
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue({})
				end).to.throw()
			end)

			it("should add a ThemeProvider into the returned Roact element", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeThemeProvider = true
				})

				expect(findProviderInDescendants(element, "ThemeProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.theme", function()
			it("should do nothing if extraArgs.includeThemeProvider is false", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeThemeProvider = false,
					theme = {}
				})

				expect(findProviderInDescendants(element, "ThemeProvider")).to.equal(nil)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)

			it("should expect a table", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						theme = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue({})
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue(false)
				end).to.throw()
			end)

			it("should set the correct theme", function()
				local testTheme = {
					testValue = "hello world"
				}

				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeThemeProvider = true,
					theme = testTheme
				})

				local themeProvider = findProviderInDescendants(element, "ThemeProvider")
				expect(themeProvider).to.be.ok()

				local theme = themeProvider.props["theme"]
				expect(theme).to.equal(testTheme)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.includeStyleProvider", function()
			it("should expect a boolean", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						includeStyleProvider = value,
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(false)
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue({})
				end).to.throw()
			end)

			it("should add a StyleProvider into the returned Roact element when set to true", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeStyleProvider = true,
				})

				expect(findProviderInDescendants(element, "StyleProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.appStyle", function()
			local style = {
				themeName = StyleConstants.ThemeName.Dark,
				fontName = StyleConstants.FontName.Gotham,
			}
			it("should do nothing if extraArgs.includeStyleProvider is false", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeStyleProvider = false,
					appStyle = style,
				})

				expect(findProviderInDescendants(element, "StyleProvider")).to.equal(nil)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)

			it("should set the style", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeStyleProvider = true,
					appStyle = style,
				})

				expect(findProviderInDescendants(element, "StyleProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)

			end)
		end)

		describe("extraArgs.includeAppPolicyProvider", function()
			it("should expect a boolean", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						includeAppPolicyProvider = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(false)
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue({})
				end).to.throw()
			end)

			it("should add an AppPolicyProvider into the returned Roact element", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeAppPolicyProvider = true
				})

				local storeProvider = findProviderInDescendants(element, "StoreProvider")
				expect(storeProvider).to.be.ok()
				expect(findProviderInDescendants(storeProvider, "AppPolicyProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)


		describe("extraArgs.includeLocalizationProvider", function()
			it("should expect a boolean", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						includeLocalizationProvider = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(false)
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue({})
				end).to.throw()
			end)

			it("should add a LocalizationProvider into the returned Roact element", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeLocalizationProvider = true
				})

				expect(findProviderInDescendants(element, "LocalizationProvider")).to.be.ok()

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.localization", function()
			it("should do nothing if extraArgs.includeLocalizationProvider is false", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeLocalizationProvider = false,
					localization = {}
				})

				expect(findProviderInDescendants(element, "LocalizationProvider")).to.equal(nil)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)

			it("should expect a table", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						localization = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue({})
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue(false)
				end).to.throw()
			end)

			it("should set the correct localization", function()
				local testLocalization = {
					testValue = "hello world"
				}

				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeLocalizationProvider = true,
					localization = testLocalization
				})

				local localizationProvider = findProviderInDescendants(element, "LocalizationProvider")
				expect(localizationProvider).to.be.ok()

				local localization = localizationProvider.props["localization"]
				expect(localization).to.equal(testLocalization)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.appPolicy", function()
			it("should do nothing if extraArgs.includeAppPolicyProvider is false or not included", function()
				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					appPolicy = {}
				})

				expect(findProviderInDescendants(element, "AppPolicyProvider")).to.equal(nil)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)

			it("should expect a table", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						appPolicy = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue({})
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue(false)
				end).to.throw()
			end)

			it("should set the correct appPolicy", function()
				local testAppPolicy = {
					testValue = "hello world"
				}

				local testComponent = function() end
				local element = mockServices({
					tc = Roact.createElement(testComponent)
				}, {
					includeAppPolicyProvider = true,
					appPolicy = testAppPolicy
				})

				local storeProvider = findProviderInDescendants(element, "StoreProvider")
				expect(storeProvider).to.be.ok()
				local appPolicyProvider = findProviderInDescendants(storeProvider, "AppPolicyProvider")
				expect(appPolicyProvider).to.be.ok()

				local appPolicy = appPolicyProvider.props["policy"]
				expect(appPolicy).to.equal(testAppPolicy)

				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end)

		describe("extraArgs.extraServices", function()
			it("should expect a table", function()
				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						extraServices = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue({})
				end).to.be.ok()

				expect(function()
					testValue("hello world")
				end).to.throw()

				expect(function()
					testValue(false)
				end).to.throw()
			end)

			it("should expect a valid extraServices map with table keys", function()
				local fakeService = RoactServices.createService("test")
				local validFakeService = {
					[fakeService] = "test",
				}

				local invalidFakeService = {
					test1 = "haha",
				}

				local function testValue(value)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						extraServices = value
					})
					local instance = Roact.mount(element)
					Roact.unmount(instance)
				end

				expect(function()
					testValue(invalidFakeService)
				end).to.throw()

				expect(function()
					testValue(validFakeService)
				end).to.be.ok()
			end)

			it("should map extraServices to the services prop", function()
				local fakeService = RoactServices.createService("test")
				local validFakeService = {
					[fakeService] = {},
				}

				local function createElement(fakeServices)
					local testComponent = function() end
					local element = mockServices({
						tc = Roact.createElement(testComponent)
					}, {
						extraServices = fakeServices
					})

					return element
				end

				local element = createElement(validFakeService)
				local instance = Roact.mount(element)

				expect(element.props.services[fakeService]).to.equal(validFakeService[fakeService])

				Roact.unmount(instance)
			end)
		end)
	end)
end
