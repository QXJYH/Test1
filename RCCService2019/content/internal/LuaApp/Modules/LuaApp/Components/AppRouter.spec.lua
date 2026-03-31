return function()
	local AppRouter = require(script.Parent.AppRouter)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local AppPage = require(Modules.LuaApp.AppPage)
	local AppPageProperties = require(Modules.LuaApp.AppPageProperties)
	local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

	it("should create and destroy without errors", function()
		local element = mockServices({
			Router = Roact.createElement(AppRouter, {
				pageConstructors = {
					[AppPage.Home] = function(visible)
						return nil
					end,
					[AppPage.Startup] = function(visible)
						return nil
					end,
				}
			}),
		}, {
			includeStoreProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create a page for each route in the history, with only the top one visible", function()
		local store = MockStore.new()

		local pageConstructors = {
			[AppPage.Startup] = function(navigationProps)
				return Roact.createElement("TextLabel", {
					Visible = navigationProps.isVisible,
					LayoutOrder = navigationProps.displayOrder,
					Text = AppPage.Startup,
				})
			end,
			[AppPage.Home] = function(navigationProps)
				return Roact.createElement("TextLabel", {
					Visible = navigationProps.isVisible,
					LayoutOrder = navigationProps.displayOrder,
					Text = AppPage.Home,
				})
			end,
			[AppPage.GamesList] = function(navigationProps, detail)
				return Roact.createElement("TextLabel", {
					Visible = navigationProps.isVisible,
					LayoutOrder = navigationProps.displayOrder,
					Text = string.format(AppPage.GamesList .. ":" .. detail),
				})
			end,
			[AppPage.GameDetail] = function(navigationProps, detail)
				return Roact.createElement("TextLabel", {
					Visible = navigationProps.isVisible,
					LayoutOrder = navigationProps.displayOrder,
					Text = string.format(AppPage.GameDetail .. ":" .. detail),
				})
			end,
		}

		local element = mockServices({
			Router = Roact.createElement(AppRouter, {
				pageConstructors = pageConstructors,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
		})
		local container = Instance.new("Folder")
		Roact.mount(element, container, "RouteTest")

		local rootPageName = FlagSettings.GetDefaultAppPage()
		expect(container).to.be.ok()
		expect(container.RouteTest).to.be.ok()
		expect(container.RouteTest[rootPageName]).to.be.ok()
		expect(container.RouteTest[rootPageName].Text).to.equal(rootPageName)
		expect(container.RouteTest[rootPageName].Visible).to.equal(true)

		store:dispatch(NavigateDown({ name = AppPage.GamesList, detail = "popular" }))
		store:flush()
		local gamesListName = AppPage.GamesList .. ":popular"

		expect(container.RouteTest[rootPageName]).to.be.ok()
		expect(container.RouteTest[rootPageName].Text).to.equal(rootPageName)
		expect(container.RouteTest[rootPageName].Visible).to.equal(false)
		expect(container.RouteTest[gamesListName]).to.be.ok()
		expect(container.RouteTest[gamesListName].Text).to.equal(gamesListName)
		expect(container.RouteTest[gamesListName].Visible).to.equal(true)

		store:dispatch(NavigateDown({ name = AppPage.GameDetail, detail = "123456" }))
		store:flush()
		local gameDetailName = AppPage.GameDetail .. ":123456"

		expect(container.RouteTest[rootPageName]).to.be.ok()
		expect(container.RouteTest[rootPageName].Text).to.equal(rootPageName)
		expect(container.RouteTest[rootPageName].Visible).to.equal(false)
		expect(container.RouteTest[gamesListName]).to.be.ok()
		expect(container.RouteTest[gamesListName].Text).to.equal(gamesListName)

		local isGameDetailsTransparent = AppPageProperties[AppPage.GameDetail].renderUnderlyingPage
		expect(container.RouteTest[gamesListName].Visible).to.equal(isGameDetailsTransparent)

		expect(container.RouteTest[gameDetailName]).to.be.ok()
		expect(container.RouteTest[gameDetailName].Text).to.equal(gameDetailName)
		expect(container.RouteTest[gameDetailName].Visible).to.equal(true)

		if isGameDetailsTransparent then
			expect(container.RouteTest[gameDetailName].LayoutOrder >
				container.RouteTest[gamesListName].LayoutOrder).to.equal(true)
		end
	end)
end
