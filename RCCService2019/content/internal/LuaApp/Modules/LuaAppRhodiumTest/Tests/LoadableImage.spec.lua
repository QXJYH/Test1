local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp
local withServices = require(script.Parent.Parent.withServices)
local LoadableImage = require(LuaApp.Components.LoadableImage)

local defaultLoadImage = "rbxasset://textures/ui/LuaApp/icons/ic-game.png"

return function()
	describe("LoadableImage", function()
		it("should show the loading image and then load the expected image correctly", function()
			local testImage = "https://t5.rbxcdn.com/ed422c6fbb22280971cfb289f40ac814"
			local props = {
				Image = testImage,
				Size = UDim2.new(0, 80, 0, 80),
				Position = UDim2.new(0, 50, 0, 50),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0,0,0),
				loadingImage = defaultLoadImage,
			}

			withServices(function(path)
				local loadableImagePath = Rhodium.XPath.new(path)
				local loadableImage = Rhodium.Element.new(loadableImagePath)
				expect(loadableImage:waitForRbxInstance(10)).to.be.ok()
				expect(loadableImage:getAttribute("Image")).to.equal(defaultLoadImage)
				wait(1)
				expect(loadableImage:getAttribute("Image")).to.equal(testImage)
			end,
			LoadableImage, nil, props)
		end)

		it("should show the expected image immediately if it has been cached", function()
			local testImage = "http://www.roblox.com/asset/?id=1451809419"
			local props = {
				Image = testImage,
				Size = UDim2.new(0, 80, 0, 80),
				Position = UDim2.new(0, 50, 0, 50),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0,0,0),
				loadingImage = defaultLoadImage,
			}

			withServices(function(path)
				local loadableImagePath = Rhodium.XPath.new(path)
				Rhodium.Element.new(loadableImagePath)
				wait(1)
			end,
			LoadableImage, nil, props)

			withServices(function(path)
				local loadableImagePath = Rhodium.XPath.new(path)
				local loadableImage = Rhodium.Element.new(loadableImagePath)
				expect(loadableImage:waitForRbxInstance(10)).to.be.ok()
				expect(loadableImage:getAttribute("Image")).to.equal(testImage)
			end,
			LoadableImage, nil, props)
		end)
	end)
end