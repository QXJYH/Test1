return function()
	local GameMediaAccordionView = require(script.Parent.GameMediaAccordionView)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testGameMediaAccordionView(storeState, props)
		local store = Rodux.Store.new(AppReducer, storeState)

		local element = mockServices({
			Accordion = Roact.createElement(GameMediaAccordionView, props)
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end

	describe("GameMediaAccordionView", function()
		it("should create and destroy without errors without media entry", function()
			testGameMediaAccordionView({
				GameMedia = {}
			}, {
				universeId = "1234",
				placeId = "5678",
				width = 335,
			})
		end)

		it("should create and destroy without errors with empty media entry", function()
			testGameMediaAccordionView({
				GameMedia = { [1234] = {} }
			}, {
				universeId = "1234",
				width = 335,
			})
		end)

		it("should create and destroy without errors with media entry", function()
			testGameMediaAccordionView({
				GameMedia = {
					[1234] = {
						id = "id",
						assetTypeId = 1,
						imageId = "4567",
						approved = true,
					}
				}
			}, {
				universeId = "1234",
				width = 335,
			})
		end)
	end)
end
