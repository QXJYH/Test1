local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local withServices = require(script.Parent.Parent.Parent.withServices)

local Roact = require(CorePackages.Roact)
local Promise = require(LuaApp.Promise)
local RefreshScrollingFrameNew = require(LuaApp.Components.RefreshScrollingFrameNew)

return function()
	local refresh = function()
		return Promise.resolve("success")
	end

	it("should create a functional scrolling frame that holds the contents", function()
		local contentHeight = 600
		local props = {
			Position = UDim2.new(0, 0, 0, 10),
			Size = UDim2.new(0, 200, 0, 300),
			refresh = refresh,
			parentAppPage = "Test",
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

			wait(0.1)
			expect(scrollingFrame:getAttribute("Size")).to.equal(props.Size)
			expect(scrollingFrame:getAttribute("Position")).to.equal(props.Position)
			expect(scrollingFrame:getAttribute("CanvasSize").Y.Offset == contentHeight).to.equal(true)

			-- Check scrolling functionaility
			if UserInputService.MouseEnabled then
				Rhodium.VirtualInput.mouseWheel(scrollingFrame:getCenter(), 2)
			elseif UserInputService.TouchEnabled then
				Rhodium.VirtualInput.swipe(scrollingFrame:getCenter(),
					scrollingFrame:getCenter() + Vector2.new(0, -20), 0.25, false)
			end
			wait(0.1)

			expect(scrollingFrame:getAttribute("CanvasPosition").Y > 0).to.equal(true)
		end,
		RefreshScrollingFrameNew, nil, props)
	end)
end