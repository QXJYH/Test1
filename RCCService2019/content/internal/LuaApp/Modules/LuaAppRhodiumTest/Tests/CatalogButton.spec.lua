local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Rhodium = game.CoreGui.RobloxGui.Modules.Rhodium
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp
local Element = require(Rhodium.Element)
local XPath = require(Rhodium.XPath)
local withServices = require(script.Parent.Parent.withServices)
local DeviceOrientationMode = require(game.CoreGui.RobloxGui.Modules.LuaApp.DeviceOrientationMode)
local CatalogButton = require(LuaApp.Components.Avatar.UI.CatalogButton)
local ContextWrapper = require(Modules.LuaApp.TestHelpers.ContextWrapper)

return function()
    describe("CatalogButton", function()
        it("should render the CatalogButton component", function()
            local props = {
                deviceOrientation = DeviceOrientationMode.Portrait,
            }

            local wrappedComponent = ContextWrapper.wrap(CatalogButton)

            withServices(function(path)
                path = XPath.new(path)
                local baseWidget = Element.new(path)
                expect(baseWidget:waitForRbxInstance(1)).to.be.ok()
            end,
            wrappedComponent, nil, props)
        end)
    end)
end