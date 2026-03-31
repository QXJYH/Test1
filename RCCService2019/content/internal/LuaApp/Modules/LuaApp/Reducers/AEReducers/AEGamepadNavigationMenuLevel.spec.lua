return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AEGamepadNavigationMenuLevel = require(script.Parent.AEGamepadNavigationMenuLevel)
	local AESetGamepadNavigationMenuLevel = require(Modules.LuaApp.Actions.AEActions.AESetGamepadNavigationMenuLevel)
	local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)

	it("should be unchanged by other actions", function()
		local oldState = AEGamepadNavigationMenuLevel(nil, {})
		local newState = AEGamepadNavigationMenuLevel(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should be set to Category Menu by default", function()
		local state = AEGamepadNavigationMenuLevel(nil, {})
		expect(state).to.equal(AEConstants.GamepadNavigationMenuLevel.CategoryMenu)
	end)

	it("should change the menu level with AESetGamepadNavigationMenuLevel", function()
		local newState = AEGamepadNavigationMenuLevel(nil, AESetGamepadNavigationMenuLevel(AEConstants.GamepadNavigationMenuLevel.AssetsPage))
		expect(newState).to.equal(AEConstants.GamepadNavigationMenuLevel.AssetsPage)
	end)
end