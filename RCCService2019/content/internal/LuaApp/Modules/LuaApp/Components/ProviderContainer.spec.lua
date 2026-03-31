return function()
	local ProviderContainer = require(script.Parent.ProviderContainer)
	local CorePackages = game:GetService("CorePackages")
	local CoreGui = game:GetService("CoreGui")
	local Modules = CoreGui.RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function Foo()
		return Roact.createElement("Frame")
	end

	it("should create and destroy without errors, without providers", function()
		local element = mockServices({
			ProviderContainer = Roact.createElement(ProviderContainer, {})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors, with providers", function()
		local element = mockServices({
			ProviderContainer = Roact.createElement(ProviderContainer, {
				providers = {
					{ class = Foo, }
				}
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
