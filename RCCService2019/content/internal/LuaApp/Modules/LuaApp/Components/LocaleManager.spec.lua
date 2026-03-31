return function()
	local LocaleManager = require(script.Parent.LocaleManager)
	local CorePackages = game:GetService("CorePackages")
	local CoreGui = game:GetService("CoreGui")
	local Modules = CoreGui.RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local Localization = require(Modules.LuaApp.Localization)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(LocaleManager, {
			localization = Localization.mock()
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
