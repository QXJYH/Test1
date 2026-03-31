local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp

local Roact = require(CorePackages.Roact)
local mockServices = require(LuaApp.TestHelpers.mockServices)

local Spinner = require(LuaApp.Components.Spinner)

local TestRoot = function(spinnerProps)
	return Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Spinner = mockServices( {
			Root = Roact.createElement(Spinner, spinnerProps),
		}, {
			includeStyleProvider = true,
		}),
	})
end

return function()
	it("should successfully create a spinner with correct configurations", function()
		local props = {
			Size = UDim2.new(0, 40, 0, 40),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0, 100, 0, 200),
		}

		local root = Roact.createElement(TestRoot, props)

		local instance = Roact.mount(root, CoreGui, "TestRoot")

		local rootPathStr = "game.CoreGui.TestRoot.Spinner"
		local rootPath = Rhodium.XPath.new(rootPathStr)
		local spinner = Rhodium.Element.new(rootPath)
		expect(spinner:waitForRbxInstance(1)).to.be.ok()

		expect(spinner:getAttribute("Size")).to.equal(props.Size)
		expect(spinner:getAttribute("Position")).to.equal(props.Position)
		expect(spinner:getAttribute("AnchorPoint")).to.equal(props.AnchorPoint)

		Roact.unmount(instance)
	end)

	it("should start spinning when isSpinning is true and stop when it's false", function()
		local TestRoot = function(spinnerProps)
			return Roact.createElement("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			}, {
				Spinner = mockServices( {
					Root = Roact.createElement(Spinner, spinnerProps),
				}, {
					includeStyleProvider = true,
				}),
			})
		end

		local root = Roact.createElement(TestRoot, {
			Size = UDim2.new(0, 40, 0, 40),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0, 100, 0, 200),
		})

		local instance = Roact.mount(root, CoreGui, "TestRoot")

		local rootPathStr = "game.CoreGui.TestRoot.Spinner"
		local rootPath = Rhodium.XPath.new(rootPathStr)
		local spinner = Rhodium.Element.new(rootPath)

		expect(spinner:getAttribute("Rotation")).to.equal(0)

		-- Start Spinning
		Roact.reconcile(instance, Roact.createElement(TestRoot, {
			Size = UDim2.new(0, 40, 0, 40),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0, 100, 0, 200),
			isSpinning = true,
		}))

		wait(0.1)
		local rotation = spinner:getAttribute("Rotation")
		expect(rotation > 0).to.equal(true)

		wait(0.1)
		local rotation2 = spinner:getAttribute("Rotation")
		expect(rotation2 > rotation).to.equal(true)

		-- Stop Spinning
		Roact.reconcile(instance, Roact.createElement(TestRoot, {
			Size = UDim2.new(0, 40, 0, 40),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0, 100, 0, 200),
			isSpinning = false,
		}))

		wait(0.1)
		local rotation3 = spinner:getAttribute("Rotation")
		expect(rotation3).to.equal(rotation2)

		wait(0.1)
		local rotation4 = spinner:getAttribute("Rotation")
		expect(rotation4).to.equal(rotation3)

		Roact.unmount(instance)
	end)
end