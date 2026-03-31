return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local FitImageTextFrame = require(script.parent.FitImageTextFrame)

	local function MockFitImageTextFrame(props)
		return mockServices({
			FitImageTextFrame = Roact.createElement(FitImageTextFrame, props)
		}, {
			includeStoreProvider = true,
		})
	end

	describe("FitImageTextFrame", function()
		local ICON_IMAGE = "LuaApp/icons/GameDetails/playing_small"

		it("should create and destroy without errors", function()
			local element = MockFitImageTextFrame()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should create and destroy without errors with a icon + localized text", function()
			local props = {
				Image = ICON_IMAGE,
				Text = "100%",
				imageSize = 12,
				useLocalizedText = false,
			}
			local element = MockFitImageTextFrame(props)
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should create and destroy without errors with a icon + none-localized text", function()
			local props = {
				Image = ICON_IMAGE,
				Text = "CommonUI.Features.Label.Game",
				imageSize = 12,
				useLocalizedText = true,
			}
			local element = MockFitImageTextFrame(props)
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end