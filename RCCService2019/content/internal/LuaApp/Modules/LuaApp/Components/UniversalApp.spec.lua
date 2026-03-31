return function()
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local UniversalApp = require(Modules.LuaApp.Components.UniversalApp)

	-- TODO: Fix underlying shutdown problems so that we can actually run
	-- this test. See MOBLUAPP-1310.
	SKIP()

	it("should create and destroy without errors", function()
		local instance = Roact.mount(Roact.createElement(UniversalApp))
		Roact.unmount(instance)
	end)
end
