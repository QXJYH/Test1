local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local withServices = require(script.Parent.Parent.Parent.withServices)

local Roact = require(CorePackages.Roact)
local Promise = require(LuaApp.Promise)
local RefreshScrollingFrameNew = require(LuaApp.Components.RefreshScrollingFrameNew)

local REFRESH_THRESHOLD = 25

return function()
	local function tryScrollByDistance(scrollingFrame, distance)
		local scrollStep = distance > 0 and 20 or -20
		local canvasPosition = 0

		for _ = 1, 10 do
			if UserInputService.MouseEnabled then
				Rhodium.VirtualInput.mouseWheel(scrollingFrame:getCenter(), 2)
			elseif UserInputService.TouchEnabled then
				Rhodium.VirtualInput.swipe(scrollingFrame:getCenter(),
					scrollingFrame:getCenter() + Vector2.new(0, scrollStep), 0.25, false)
			end
			wait(0.01)

			canvasPosition = scrollingFrame:getAttribute("CanvasPosition").Y
			if math.abs(canvasPosition) >= math.abs(distance) then
				break
			end
		end

		return math.abs(canvasPosition)
	end

	it("should refresh if scrolling frame is pulled down and released for more than the refresh threshold", function()
		if not UserInputService.TouchEnabled then
			-- Refresh only works in touch.
			return
		end

		local refreshCount = 0
		local refresh = function()
			wait(0.1)
			refreshCount = refreshCount + 1
			return Promise.resolve("success")
		end

		local contentHeight = 600
		local props = {
			Position = UDim2.new(0, 0, 0, 10),
			Size = UDim2.new(0, 200, 0, 300),
			refresh = refresh,
			parentAppPage = "Test",
			refreshThreshold = REFRESH_THRESHOLD,
			[Roact.Children] = {
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, contentHeight),
					BackgroundTransparency = 1,
				}, {
					Text = Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 0, 30),
						Text = "Test RefreshScrollingFrameNew",
					}),
				}),
			},
		}

		withServices(function(rootPathStr)
			local rootPath = Rhodium.XPath.new(rootPathStr)
			local scrollingFrame = Rhodium.Element.new(rootPath)
			expect(scrollingFrame:waitForRbxInstance(1)).to.be.ok()

			if tryScrollByDistance(scrollingFrame, REFRESH_THRESHOLD + 1) > REFRESH_THRESHOLD then
				wait(0.2)
				expect(refreshCount).to.equal(1)
			else
				warn("Cannot pull the scrollingframe to appropriate position for proper testing!")
			end
		end,
		RefreshScrollingFrameNew, nil, props)
	end)

	it("should NOT refresh if scrolling frame is pulled down and released for less than the refresh threshold", function()
		if not UserInputService.TouchEnabled then
			-- Refresh only works in touch.
			return
		end

		local refreshCount = 0
		local refresh = function()
			wait(0.1)
			refreshCount = refreshCount + 1
			return Promise.resolve("success")
		end

		local contentHeight = 600
		local props = {
			Position = UDim2.new(0, 0, 0, 10),
			Size = UDim2.new(0, 200, 0, 300),
			refresh = refresh,
			parentAppPage = "Test",
			refreshThreshold = REFRESH_THRESHOLD,
			[Roact.Children] = {
				Frame = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, contentHeight),
					BackgroundTransparency = 1,
				}, {
					Text = Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 0, 30),
						Text = "Test RefreshScrollingFrameNew",
					}),
				}),
			},
		}

		withServices(function(rootPathStr)
			local rootPath = Rhodium.XPath.new(rootPathStr)
			local scrollingFrame = Rhodium.Element.new(rootPath)
			expect(scrollingFrame:waitForRbxInstance(1)).to.be.ok()

			if tryScrollByDistance(scrollingFrame, REFRESH_THRESHOLD / 2) < REFRESH_THRESHOLD then
				wait(0.2)
				expect(refreshCount).to.equal(0)
			else
				warn("Cannot pull the scrollingframe to appropriate position for proper testing!")
			end
		end,
		RefreshScrollingFrameNew, nil, props)
	end)
end