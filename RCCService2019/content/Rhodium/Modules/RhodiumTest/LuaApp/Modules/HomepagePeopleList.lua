describe = nil
step = nil
expect = nil
include = nil

local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Constants = require(Modules.LuaApp.Constants)
local Element = require(Modules.Rhodium.Element)
local MobileAppElements = require(Modules.RhodiumTest.Common.MobileAppElements)
local PageNavigation = require(Modules.RhodiumTest.Common.PageNavigation)
local VirtualInput = require(Modules.Rhodium.VirtualInput)

local FRIEND_CAROUSEL = {
	Username_Font = Enum.Font.SourceSansLight,
	Username_TextColor = Constants.Color.GRAY1,
	Phone = {
		WIDTH = 115,
		HEIGHT = 135,
		ICON_SIZE = 84,
	},
	Tablet = {
		WIDTH = 105,
		HEIGHT = 143,
		ICON_SIZE = 90,
	}
}

return function()
	describe.protected("Homepage People List Rhodium Test", function()
		-- func step is executed step by step
		local peopleList
		local firstFriendCarousel

		step("Navigate to homepage", function()
			-- make sure we are at homepage now
			PageNavigation.gotoHomePage()
		end)

		step("Load elements", function()
			peopleList = MobileAppElements.homePagePeopleList:waitForFirstInstance()
			assert(peopleList, "create people list unsuccessfully")

			-- First friend carousel
			firstFriendCarousel = peopleList["1"]
			assert(firstFriendCarousel)
		end)

		describe.protected("Test user carousel on people list", function()
			step.protected("User carousel layout", function()
				local headIcon = firstFriendCarousel.ThumbnailFrame.Thumbnail.Image
				local userName = firstFriendCarousel.ThumbnailFrame.Thumbnail.Username

				assert(headIcon, "can not find head icon")
				assert(userName, "can not find username label")

				-- Tablet
				if firstFriendCarousel.AbsoluteSize.x == FRIEND_CAROUSEL.Tablet.WIDTH then
					assert(firstFriendCarousel.AbsoluteSize.y == FRIEND_CAROUSEL.Tablet.HEIGHT)
					assert(headIcon.AbsoluteSize.x == FRIEND_CAROUSEL.Tablet.ICON_SIZE)
				else
					-- Phone
					assert(firstFriendCarousel.AbsoluteSize.x == FRIEND_CAROUSEL.Phone.WIDTH)
					assert(firstFriendCarousel.AbsoluteSize.y == FRIEND_CAROUSEL.Phone.HEIGHT)
					assert(headIcon.AbsoluteSize.x == FRIEND_CAROUSEL.Phone.ICON_SIZE)
				end

				assert(userName.TextColor3 == FRIEND_CAROUSEL.Username_TextColor)
				assert(userName.Font == FRIEND_CAROUSEL.Username_Font)
			end)
		end)

		describe.protected("Test scrolling frame of people list", function()
			step.protected("People List Scrolling test", function ()
				local screenWidth = peopleList.AbsoluteSize.x
				local peopleListContentSize = peopleList.CanvasSize.X.Offset

				local startPoint = Element.new(peopleList):getCenter()
				-- Move to left 100 pixel
				-- This number should be larger.
				-- if it's too small, the scrolling frame would be scrolled
				local endPoint = Vector2.new(startPoint.X - 100, startPoint.Y)
				VirtualInput.swipe(startPoint, endPoint, 0.2)
				wait(0.5)

				if peopleListContentSize > screenWidth then
					assert(peopleList.CanvasPosition.X > 0, "Can not move people list")
				else
					assert(peopleList.CanvasPosition.X == 0, "Can move a non-scrollable people list")
				end
			end)
		end)
	end)
end