return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local SearchPage = require(Modules.LuaApp.Components.Search.SearchPage)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)

	it("should create and destroy without errors", function()
		local store = {
			SearchesInGames = {},
			SearchesParameters = { [1] = {
				searchKeyword = "Meep",
				isKeywordSuggestionEnabled = true,
			}},
		}
		local mockSearchResult = {
			games = {},
		}
		local element = mockServices({
			searchPage = Roact.createElement(SearchPage, {
				searchUuid = 1,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			extraServices = {
				[RoactNetworking] = MockRequest.simpleSuccessRequest(mockSearchResult),
			},
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
