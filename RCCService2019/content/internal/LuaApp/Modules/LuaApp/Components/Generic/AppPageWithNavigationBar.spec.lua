return function()
	local AppPageWithNavigationBar = require(script.Parent.AppPageWithNavigationBar)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testAppPage(dataStatus)
		local store = {
			ScreenSize = Vector2.new(100, 100),
			FormFactor = FormFactor.COMPACT,
		}

		local element = mockServices({
			Item = Roact.createElement(AppPageWithNavigationBar, {
				title = "CommonUI.Features.Label.Home",
				dataStatus = dataStatus,
				renderContentOnLoading = function() end,
				renderContentOnLoaded = function() end,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when data is loaded", function()
		testAppPage(RetrievalStatus.Done)
	end)

	it("should create and destroy without errors when data is loading/not started", function()
		testAppPage(RetrievalStatus.Fetching)
		testAppPage(RetrievalStatus.NotStarted)
	end)

	it("should create and destroy without errors when data failed to load", function()
		testAppPage(RetrievalStatus.Failed)
	end)
end
