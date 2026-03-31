return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local HttpService = game:GetService("HttpService")
	local Roact = require(Modules.Common.Roact)
	local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
	local MockGuiService = require(Modules.LuaApp.TestHelpers.MockGuiService)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local NotificationType = require(Modules.LuaApp.Enum.NotificationType)

	local GenericNativePageWrapper = require(script.parent.GenericNativePageWrapper)

	describe("PurchaseRobuxPageWrapper", function()
		it("should broadcast the chosen notification when mounted", function()
			local guiService = MockGuiService.new()
			local element = mockServices({
				wrapper = Roact.createElement(GenericNativePageWrapper, {
					isVisible = true,
					notificationType = NotificationType.PURCHASE_ROBUX,
				}),
			}, {
				includeStoreProvider = true,
				extraServices = {
					[AppGuiService] = guiService,
				},
				includeAppPolicyProvider = true,
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)

			expect(#guiService.broadcasts).to.equal(1)
			expect(guiService.broadcasts[1].notification).to.equal(NotificationType.PURCHASE_ROBUX)

			local resultData = HttpService:JSONDecode(guiService.broadcasts[1].data)
			expect(resultData.animated).to.equal(true)
		end)

		-- NOTE: other test cases are covered by NativePageWrapper.spec.lua
	end)
end
