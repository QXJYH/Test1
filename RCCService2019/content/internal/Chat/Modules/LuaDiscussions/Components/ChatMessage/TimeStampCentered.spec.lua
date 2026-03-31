return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local CorePackages = game:GetService("CorePackages")
	local DateTime = require(CorePackages.AppTempCommon.LuaChat.DateTime)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local TimeStampCentered = require(script.Parent.TimeStampCentered)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(TimeStampCentered))

			cleanup()
		end)
	end)

	describe("props isoTime", function()
		it("passing '1999-01-01' should result in a text of January 1st, 1999", function()
			local iso = "1999-01-01"
			local tree = Roact.createElement(TimeStampCentered, {
				isoTime = iso,
			})
			local frame, cleanup = mountStyledFrame(tree)
			frame.Size = UDim2.new(0, 1000, 0, 1000)

			local textLabel = frame:FindFirstChildWhichIsA("TextLabel", true)
			expect(textLabel.text).to.equal(DateTime.GetLongRelativeTime(DateTime.fromIsoDate(iso)))

			cleanup()
		end)

		it("passing [current time] should result in a text in standard 00:00 notation", function()
			local time = DateTime.now():GetIsoDate()
			local tree = Roact.createElement(TimeStampCentered, {
				isoTime = time,
			})
			local frame, cleanup = mountStyledFrame(tree)
			frame.Size = UDim2.new(0, 1000, 0, 1000)

			local textLabel = frame:FindFirstChildWhichIsA("TextLabel", true)
			expect(textLabel.text).to.equal(DateTime.GetLongRelativeTime(DateTime.fromIsoDate(time)))

			cleanup()
		end)
	end)

	describe("props layoutOrder", function()
		it("should set the timestamp's frame LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(TimeStampCentered, {
				layoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)
			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)
end