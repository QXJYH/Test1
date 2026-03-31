local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local FormFactor = require(LuaApp.Enum.FormFactor)

local withServices = require(script.Parent.Parent.withServices)

local BackgroundWithMask = require(LuaApp.Components.Home.BackgroundWithMask)

local BACKGROUND_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/CityBackground.png"
local MASK_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/WideView_purpleLayer.png"

return function()
	local initialState = {
		FormFactor = FormFactor.WIDE,
		ScreenSize = game.Workspace.CurrentCamera.ViewportSize,
	}

	describe("BackgroundWithMask", function()
		it("should load the background image with a mask", function()
			withServices(function(path)
				local backgroundWithMaskPath = Rhodium.XPath.new(path)
				local backgroundWithMask = Rhodium.Element.new(backgroundWithMaskPath)
				expect(backgroundWithMask:waitForRbxInstance(10)).to.be.ok()
				expect(backgroundWithMask:getAttribute("Image")).to.equal(BACKGROUND_IMAGE)

				local maskImage = Rhodium.Element.new(backgroundWithMaskPath:cat(Rhodium.XPath.new("1")))
				expect(maskImage:getRbxInstance()).to.be.ok()
				expect(maskImage:getAttribute("Image")).to.equal(MASK_IMAGE)
			end,
			BackgroundWithMask, initialState)
		end)
	end)
end
