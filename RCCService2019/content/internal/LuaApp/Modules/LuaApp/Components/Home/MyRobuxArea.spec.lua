return function()
    local CorePackages = game:GetService("CorePackages")
    local Roact = require(CorePackages.Roact)
    local Modules = game:GetService("CoreGui").RobloxGui.Modules
    local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
    local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
    local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
    local MyRobuxArea = require(Modules.LuaApp.Components.Home.MyRobuxArea)

	it("should create and destroy without errors if data is ready", function()
		local store = {
            LocalUserId = "12345",
            UserRobux = {
                ["12345"] = 54321,
            }
        }

		local element = mockServices({
            MyRobuxArea = Roact.createElement(MyRobuxArea)
		}, {
            includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
    end)

    it("should create and destroy without errors if robux is not ready", function()
		local store = {
            LocalUserId = "12345",
        }

        local mockRequestResult = {
            robux = 54321,
        }

        local networkImpl = MockRequest.simpleSuccessRequest(mockRequestResult)

		local element = mockServices({
            MyRobuxArea = Roact.createElement(MyRobuxArea)
		}, {
            includeThemeProvider = true,
			includeStoreProvider = true,
            store = store,
            extraServices = {
				[RoactNetworking] = networkImpl,
			},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

    it("should create and destroy without errors if store is empty", function()
        local element = mockServices({
            MyRobuxArea = Roact.createElement(MyRobuxArea)
        }, {
            includeThemeProvider = true,
            includeStoreProvider = true,
        })

        local instance = Roact.mount(element)
        Roact.unmount(instance)
    end)
end
