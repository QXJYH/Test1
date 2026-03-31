local Rhodium = game.CoreGui.RobloxGui.Modules.Rhodium
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local Element = require(Rhodium.Element)
local XPath = require(Rhodium.XPath)
local withServices = require(script.Parent.Parent.Parent.withServices)
local UniversalBottomBar = require(LuaApp.Components.UniversalBottomBar)

local BOTTOM_BAR_HEIGHT = 48
local bottomBarPath = XPath.new("game.CoreGui.BottomBar")

return function()
	it("should load UniversalBottomBar when there is no item inside it", function()
		local props = {
			isVisible = true,
			displayOrder = 1,
			layoutInfo = {
				Background = {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.new(1, 0, 0, BOTTOM_BAR_HEIGHT),
				},
				TopBorder = {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 1, -BOTTOM_BAR_HEIGHT),
					Size = UDim2.new(1, 0, 0, 1),
				},
			},
			renderItem = function() end,
		}

		withServices(function(path)
			local universalBottomBar = Element.new(bottomBarPath)
			expect(universalBottomBar:waitForRbxInstance(1)).to.be.ok()
			expect(universalBottomBar:getAttribute("Enabled")).to.equal(props.isVisible)
			expect(universalBottomBar:getAttribute("DisplayOrder")).to.equal(props.displayOrder)

			local background = Element.new(bottomBarPath:cat(XPath.new("Background")))
			expect(background:getRbxInstance()).to.be.ok()
			expect(background:getAttribute("Size")).to.equal(props.layoutInfo.Background.Size)

			local topBorder = Element.new(bottomBarPath:cat(XPath.new("TopBorder")))
			expect(topBorder:getRbxInstance()).to.be.ok()
		end,
		UniversalBottomBar, nil, props)
	end)
end