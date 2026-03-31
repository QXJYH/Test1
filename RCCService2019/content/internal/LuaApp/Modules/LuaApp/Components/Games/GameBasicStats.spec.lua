return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Constants = require(Modules.LuaApp.Constants)
	local GameBasicStats = require(Modules.LuaApp.Components.Games.GameBasicStats)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testGameBasicStats(upVotes, downVotes, voteText)
		local element = mockServices({
			GameBasicStats = Roact.createElement(GameBasicStats, {
				playerCount = 100,
				upVotes = upVotes,
				downVotes = downVotes,
				themeInfo = {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 0.3,
					Font = Enum.Font.SourceSans,
				},
				layoutType = Constants.GameBasicStatsLayoutType.GameDetails,
			})
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "GameBasicStats")

		local voteTextLabel = container.GameBasicStats.VoteInfo:FindFirstChild("Text", false)
		expect(voteTextLabel ~= nil).to.equal(true)
		expect(voteTextLabel.Text).to.equal(voteText)

		Roact.unmount(instance)
	end

	local function testGameBasicStatsLayoutType(layoutType)
		local element = mockServices({
			GameBasicStats = Roact.createElement(GameBasicStats, {
				playerCount = 100,
				themeInfo = {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 0.3,
					Font = Enum.Font.SourceSans,
				},
				layoutType = layoutType,
			})
		})
		return element
	end

	it("should display correctly when both votes are non zero", function()
		testGameBasicStats(90, 10, "90%")
	end)

	it("should display correctly when both votes are 0", function()
		testGameBasicStats(0, 0, "--")
	end)

	it("should display correctly when one vote is 0 and the other is not", function()
		testGameBasicStats(0, 2, "0%")
		testGameBasicStats(2, 0, "100%")
	end)

	it("should create and destroy without errors when there're no votes", function()
		testGameBasicStats(nil, nil, "--")
	end)

	it("should throw when created without layoutType", function()
		local element = testGameBasicStatsLayoutType(nil)
		expect(function() return Roact.mount(element) end).to.throw()
	end)

	it("should throw when created with unsupported layoutType", function()
		local element = testGameBasicStatsLayoutType("test")
		expect(function() return Roact.mount(element) end).to.throw()
	end)
end