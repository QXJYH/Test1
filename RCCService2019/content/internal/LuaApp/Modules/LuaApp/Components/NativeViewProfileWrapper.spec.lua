return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local NativeViewProfileWrapper = require(script.parent.NativeViewProfileWrapper)

	it("should create and destroy without errors", function()
		local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")
		local Url = require(Modules.LuaApp.Http.Url)
		local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
		local url
		if FFlagLuaAppHttpsWebViews then
			url = UrlBuilder.static.friends()
		else
			url = string.format("%susers/friends", Url.BASE_URL)
		end
		local element = mockServices({
			wrapper = Roact.createElement(NativeViewProfileWrapper, {
				isVisible = true,
				url = url,
			}),
		}, {
			includeStoreProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
