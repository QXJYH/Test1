return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local HttpService = game:GetService("HttpService")
	local Roact = require(Modules.Common.Roact)
	local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
	local MockGuiService = require(Modules.LuaApp.TestHelpers.MockGuiService)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local NotificationType = require(Modules.LuaApp.Enum.NotificationType)

	local YouTubePageWrapper = require(script.parent.YouTubePageWrapper)

	local TEST_URL = "the_test_url"
	local TEST_TITLE = "the_test_title"

	describe("YouTubePageWrapper", function()
		it("should broadcast the OPEN_YOUTUBE_VIDEO notification when mounted", function()
			local guiService = MockGuiService.new()
			local element = mockServices({
				wrapper = Roact.createElement(YouTubePageWrapper, {
					isVisible = true,
					url = TEST_URL,
					title = TEST_TITLE,
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
			expect(guiService.broadcasts[1].notification).to.equal(NotificationType.OPEN_YOUTUBE_VIDEO)

			local resultData = HttpService:JSONDecode(guiService.broadcasts[1].data)
			expect(resultData.url).to.equal(TEST_URL)
			expect(resultData.title).to.equal(TEST_TITLE)
			expect(resultData.animated).to.equal(true)
		end)

		-- NOTE: other test cases are covered by NativePageWrapper.spec.lua
	end)
end
