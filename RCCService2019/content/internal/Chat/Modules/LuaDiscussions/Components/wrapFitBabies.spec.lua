return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact

	local wrapFitBabies = require(script.Parent.wrapFitBabies)

	describe("lifecycle", function()
		it("should be able to wrap a Roblox instance and mount it", function()
			local tree = Roact.createElement(wrapFitBabies("UIListLayout"))
			local frame = Instance.new("Frame")
			local instance = Roact.mount(
				tree,
				frame
			)
			expect(instance).to.be.ok()

			local wrappedImageButton = frame:FindFirstChildWhichIsA("UIListLayout", true)
			expect(wrappedImageButton).to.be.ok()

			Roact.unmount(instance)
			frame:Destroy()
		end)

		it("should throw if UIGridStyleLayout is not present", function()
			local tree = Roact.createElement(wrapFitBabies("ImageButton"))
			local frame = Instance.new("Frame")

			expect(function()
				Roact.mount(tree, frame)
			end).to.throw()
		end)
	end)

	describe("sizing", function()
		local function getAbsoluteSize(frame)
			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			return guiObject.AbsoluteSize
		end

		it("should resize to fit a single element", function()
			local mockWidth = 100
			local mockHeight = 100
			local function component()
				return Roact.createElement("Frame", {}, {
					layout = Roact.createElement("UIListLayout"),
					frame100x100 = Roact.createElement("Frame", {
						Size = UDim2.new(UDim.new(0, mockWidth), UDim.new(0, mockHeight)),
					})
				})
			end

			local tree = Roact.createElement(wrapFitBabies(component))
			local frame = Instance.new("Frame")
			local instance = Roact.mount(
				tree,
				frame
			)
			expect(instance).to.be.ok()
			local result = getAbsoluteSize(frame)
			expect(result.X).to.equal(mockWidth)
			expect(result.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
		end)

		it("should resize to fit two vertical elements", function()
			local mockWidth = 100
			local mockHeight = 100
			local function component()
				return Roact.createElement("Frame", {}, {
					layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
					}),
					frame100x100_1 = Roact.createElement("Frame", {
						Size = UDim2.new(UDim.new(0, mockWidth), UDim.new(0, mockHeight)),
					}),
					frame100x100_2 = Roact.createElement("Frame", {
						Size = UDim2.new(UDim.new(0, mockWidth), UDim.new(0, mockHeight)),
					})
				})
			end

			local tree = Roact.createElement(wrapFitBabies(component))
			local frame = Instance.new("Frame")
			local instance = Roact.mount(
				tree,
				frame
			)
			expect(instance).to.be.ok()
			local result = getAbsoluteSize(frame)
			expect(result.X).to.equal(mockWidth)
			expect(result.Y).to.equal(mockHeight * 2)

			Roact.unmount(instance)
			frame:Destroy()
		end)

		it("should resize to fit two horizontal elements", function()
			local mockWidth = 100
			local mockHeight = 100
			local function component()
				return Roact.createElement("Frame", {}, {
					layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
					}),
					frame100x100_1 = Roact.createElement("Frame", {
						Size = UDim2.new(UDim.new(0, mockWidth), UDim.new(0, mockHeight)),
					}),
					frame100x100_2 = Roact.createElement("Frame", {
						Size = UDim2.new(UDim.new(0, mockWidth), UDim.new(0, mockHeight)),
					})
				})
			end

			local tree = Roact.createElement(wrapFitBabies(component))
			local frame = Instance.new("Frame")
			local instance = Roact.mount(
				tree,
				frame
			)
			expect(instance).to.be.ok()
			local result = getAbsoluteSize(frame)
			expect(result.X).to.equal(mockWidth * 2)
			expect(result.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
		end)
	end)
end