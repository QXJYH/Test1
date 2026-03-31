local Rhodium = game.CoreGui.RobloxGui.Modules.Rhodium
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local Element = require(Rhodium.Element)
local XPath = require(Rhodium.XPath)
local withServices = require(script.Parent.Parent.Parent.withServices)

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local UniversalBottomBar = require(LuaApp.Components.UniversalBottomBar)
local UniversalBottomBarButton = require(LuaApp.Components.UniversalBottomBarButton)

local TestingItems = require(script.Parent.UniversalBottomBarTestingItems)

local BOTTOM_BAR_HEIGHT = 48
local bottomBarPath = XPath.new("game.CoreGui.BottomBar")

return function()
	it("should load UniversalBottomBar correctly when there are items inside it", function()
		local props = {
			isVisible = true,
			displayOrder = 10,
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
			selectedIndex = 1,
			items = TestingItems,
			renderItem = function(context, selected)
				return Roact.createElement(UniversalBottomBarButton, {
					page = context.page,
					icon = context.icon,
					badgeCount = context.badgeCount,
					titleKey = context.titleKey,
					selected = selected,
					onActivated = function() end,
				})
			end,
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

			local itemFramesPath = bottomBarPath:cat(XPath.new("Background.*[.ClassName = Frame]"))
			local itemFrames = itemFramesPath:getInstances()
			expect(itemFrames).to.be.ok()
			expect(#itemFrames).to.equal(#TestingItems)

			for index, item in ipairs(TestingItems) do
				if item.badgeCount > 0 then
					local itemIcon = Element.new(bottomBarPath:cat(XPath.new("Background.ItemFrame"..index..".Item.Icon"))):getRbxInstance()
					expect(itemIcon:FindFirstChild("Badge")).to.be.ok()
				end
			end
		end,
		UniversalBottomBar, nil, props)
	end)
end