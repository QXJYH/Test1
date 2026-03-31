local Rhodium = game.CoreGui.RobloxGui.Modules.Rhodium
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local Element = require(Rhodium.Element)
local XPath = require(Rhodium.XPath)
local withServices = require(script.Parent.Parent.Parent.withServices)

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local DarkTheme = require(CorePackages.AppTempCommon.LuaApp.Style.Themes.DarkTheme)

local AppPage = require(LuaApp.AppPage)
local ClassicTheme = require(LuaApp.Themes.ClassicTheme)
local UniversalBottomBar = require(LuaApp.Components.UniversalBottomBar)
local UniversalBottomBarButton = require(LuaApp.Components.UniversalBottomBarButton)
local mockServices = require(LuaApp.TestHelpers.mockServices)

local TestingItems = require(script.Parent.UniversalBottomBarTestingItems)

local FlagSettings = require(LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local MAX_BOTTOM_BAR_WIDTH = 600
local BOTTOM_BAR_HEIGHT = 48
local UNSELECTED_TRANSPARENCY = 0.5

local bottomBarPath = XPath.new("game.CoreGui.BottomBar")
local currentSelectedIndex = 1

local testPageIndex = {}
for index, item in ipairs(TestingItems) do
	testPageIndex[item.page] = index
end

local onButtonActivated = function(page)
	currentSelectedIndex = testPageIndex[page]
end

local function getPropsWithSelectedIndex(selectedIndex)
	local screenSize = game.Workspace.CurrentCamera.ViewportSize
	local horizontalPadding = math.max((screenSize.X - MAX_BOTTOM_BAR_WIDTH)/2, 0)

	return {
		isVisible = true,
		displayOrder = 10,
		layoutInfo = {
			Background = {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, BOTTOM_BAR_HEIGHT),
			},
			Padding = {
				PaddingLeft = UDim.new(0, horizontalPadding),
				PaddingRight = UDim.new(0, horizontalPadding),
			},
			TopBorder = {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, -BOTTOM_BAR_HEIGHT),
				Size = UDim2.new(1, 0, 0, 1),
			},
		},
		selectedIndex = selectedIndex,
		items = TestingItems,
		renderItem = function(context, selected)
			return Roact.createElement(UniversalBottomBarButton, {
				page = context.page,
				icon = context.icon,
				titleKey = context.titleKey,
				badgeCount = context.badgeCount,
				selected = selected,
				onActivated = onButtonActivated,
			})
		end,
	}
end

local function testLuaBottomBarWithInstance(test, props)
	local element = mockServices({
		Root = Roact.createElement(UniversalBottomBar, props),
	}, {
		includeStoreProvider = true,
	})

	local instance = Roact.mount(element)
	local success, result = pcall(function()
		test(instance)
	end)

	Roact.unmount(instance)
	if not success then
		error(result)
	end
end

local function verifySelectedItem(selectedIndex)
	local itemFramesPath = bottomBarPath:cat(XPath.new("Background.*[.ClassName = Frame]"))
	local itemFrames = itemFramesPath:getInstances()
	for index, itemFrame in ipairs(itemFrames) do
		if UseNewAppStyle then
			expect(itemFrame.Item.Icon.ImageColor3).to.equal(DarkTheme.SystemPrimaryDefault.Color)
			if itemFrame.LayoutOrder == selectedIndex then
				expect(itemFrame.Item.Icon.ImageTransparency).to.equal(DarkTheme.SystemPrimaryDefault.Transparency)
			else
				expect(itemFrame.Item.Icon.ImageTransparency).to.equal(UNSELECTED_TRANSPARENCY)
			end
		else
			local iconTheme = ClassicTheme.BottomBarButton.Icon
			if itemFrame.LayoutOrder == selectedIndex then
				expect(itemFrame.Item.Icon.ImageColor3).to.equal(iconTheme.On.Color)
				expect(itemFrame.Item.Icon.ImageTransparency).to.equal(iconTheme.On.Transparency)
			else
				expect(itemFrame.Item.Icon.ImageColor3).to.equal(iconTheme.Off.Color)
				expect(itemFrame.Item.Icon.ImageTransparency).to.equal(iconTheme.Off.Transparency)
			end
		end
	end
end

return function()
	it("click buttons in UniversalBottomBar should highlight selected item", function()
		testLuaBottomBarWithInstance(function(luaBottomBarInstance)
			verifySelectedItem(currentSelectedIndex)

			local bottomBarItemButtons = {}
			for i = 1, #TestingItems do
				bottomBarItemButtons[i] = Element.new(bottomBarPath:cat(XPath.new("Background.ItemFrame"..i..".Item")))
			end

			for i = #bottomBarItemButtons, 1, -1 do
				bottomBarItemButtons[i]:click()
				Roact.reconcile(luaBottomBarInstance, mockServices({
					Root = Roact.createElement(UniversalBottomBar, getPropsWithSelectedIndex(i)),
				}, {
					includeStoreProvider = true,
				}))
				wait(0.2)

				verifySelectedItem(i)
				expect(currentSelectedIndex).to.equal(i)
			end
		end, getPropsWithSelectedIndex(currentSelectedIndex))
	end)
end