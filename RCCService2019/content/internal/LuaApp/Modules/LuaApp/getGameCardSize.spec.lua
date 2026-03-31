return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local getGameCardSize = require(Modules.LuaApp.getGameCardSize)
	local Constants = require(Modules.LuaApp.Constants)

	describe("getGameCardSize", function()
		it("should return accurate game card sizes and counts", function()
			local cardSize, cardCount = getGameCardSize(320.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			local footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.25)
			expect(footerHeight).to.equal(55)

			cardSize, cardCount = getGameCardSize(320.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.0)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.0)
			expect(footerHeight).to.equal(55)

			cardSize, cardCount = getGameCardSize(360.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.25)
			expect(footerHeight).to.equal(55)

			cardSize, cardCount = getGameCardSize(360.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.0)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.0)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(375.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.25)
			expect(footerHeight).to.equal(55)

			cardSize, cardCount = getGameCardSize(414.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.25)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(510.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(3.25)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(513.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.25)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(513.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.0)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.0)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(600.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.25)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(690.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.25)
			expect(footerHeight).to.equal(61)

			cardSize, cardCount = getGameCardSize(692.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(768.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(4.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(852.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(5.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(1012.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(6.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(1024.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(6.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(1172.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(7.25)
			expect(footerHeight).to.equal(67)

			cardSize, cardCount = getGameCardSize(1332.0 - Constants.GAME_CAROUSEL_PADDING,
				Constants.GAME_CAROUSEL_PADDING, Constants.GAME_CAROUSEL_CHILD_PADDING, 0.25)
			footerHeight = math.floor(cardSize.Y - cardSize.X + 0.5)
			expect(cardCount).to.equal(8.25)
			expect(footerHeight).to.equal(67)
		end)
	end)
end