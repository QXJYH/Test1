return function()
    local OpenWebview = require(script.Parent.OpenWebview)
    local Modules = game:GetService("CoreGui").RobloxGui.Modules
    local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)


    it('should only accept strings', function()
        expect(
            function()
                OpenWebview({}, "title")
            end
        ).to.throw()

        expect(
            function()
                OpenWebview("https://www.roblox.com", 123)
            end
        ).to.throw()
    end)

    it('should navigate you to a webpage', function()
        local url = "https://www.roblox.com"
        local title = "Roblox"

        local result = OpenWebview(url, title)

        local store = MockStore.new()

        expect(
            function()
                result(store)
            end
        ).to.never.throw()
    end)
end
