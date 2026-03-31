return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local GetGridLayoutSettings = require(Modules.LuaApp.GetGridLayoutSettings)

	it("should return accurate grid layout settings according to design doc", function()
		-- Medium
		local cardCount, cardWidth = GetGridLayoutSettings.Medium(280, 10)
		expect(cardCount).to.equal(2)
		expect(cardWidth).to.equal(135)

		cardCount, cardWidth = GetGridLayoutSettings.Medium(350, 10)
		expect(cardCount).to.equal(2)
		expect(cardWidth).to.equal(170)

		cardCount, cardWidth = GetGridLayoutSettings.Medium(560, 10)
		expect(cardCount).to.equal(3)
		expect(cardWidth).to.equal(180)

		cardCount, cardWidth = GetGridLayoutSettings.Medium(944, 10)
		expect(cardCount).to.equal(5)
		expect(cardWidth).to.equal(180)

		-- Large
		cardCount, cardWidth = GetGridLayoutSettings.Large(280, 10)
		expect(cardCount).to.equal(1)
		expect(cardWidth).to.equal(280)

		cardCount, cardWidth = GetGridLayoutSettings.Large(320, 10)
		expect(cardCount).to.equal(1)
		expect(cardWidth).to.equal(320)

		cardCount, cardWidth = GetGridLayoutSettings.Large(688, 10)
		expect(cardCount).to.equal(2)
		expect(cardWidth).to.equal(339)

		cardCount, cardWidth = GetGridLayoutSettings.Large(1286, 10)
		expect(cardCount).to.equal(3)
		expect(cardWidth).to.equal(422)

		-- Small
		cardCount, cardWidth = GetGridLayoutSettings.Small(280, 10)
		expect(cardCount).to.equal(3)
		expect(cardWidth).to.equal(86)

		cardCount, cardWidth = GetGridLayoutSettings.Small(320, 10)
		expect(cardCount).to.equal(3)
		expect(cardWidth).to.equal(100)

		cardCount, cardWidth = GetGridLayoutSettings.Small(560, 10)
		expect(cardCount).to.equal(4)
		expect(cardWidth).to.equal(132)

		cardCount, cardWidth = GetGridLayoutSettings.Small(944, 10)
		expect(cardCount).to.equal(6)
		expect(cardWidth).to.equal(149)
	end)
end