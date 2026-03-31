--to make ScriptAnalyzer Happy
describe = nil
step = nil
expect = nil
include = nil
-------------------------------
local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
local MobileAppElements = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.MobileAppElements)
local RobloxEventSimulator = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.RobloxEventSimulator)
local RunService = game:GetService("RunService")

return function()
	describe.protected("Home Page Should Load", function()
		if RunService:IsStudio() then
			step("should have tool bar", function()
				expect(MobileAppElements.topBar:setWait(10):waitForFirstInstance()).to.be.ok()
			end)
		end

		step("should be able to goto home page", function()
			if RunService:IsStudio() then
				Element.new(MobileAppElements.homeButton):click()
			else
				RobloxEventSimulator.gotoPage(RobloxEventSimulator.Enums.pageHome)
			end
			expect(MobileAppElements.pageName:waitForFirstInstance().Text).to.equal("Home")
		end)

		step("scroling frame should be at the top when entered home page", function()
			expect(MobileAppElements.verticalScrollingFrame:setWait(10):waitForFirstInstance().CanvasPosition.Y).to.equal(0)
		end)

		step("should have [Continue Playing] [Favorites] [Friends Playing] and [Recommended] carousels", function()
			--"Continue Playing", only if the account played some games
			--"Favorites", only if the account has favorited games
			--"Friends Playing", only if the account has friends
			-- local carouselNames = {"Continue Playing", "Favorites", "Friends Playing", "Recommended"}
			local carouselNames = {"Recommended"}
			local function checkCarousel(name)
				expect(MobileAppElements.filterBy(MobileAppElements.gameCategoryEntry,
					MobileAppElements.getGameCategoryDetail().title, "Text", name):waitForFirstInstance()).to.be.ok()
			end

			for _, name in ipairs(carouselNames) do
				checkCarousel(name)
			end
		end)
	end)
end