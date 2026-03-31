return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact

	local GenericHeader = require(script.Parent.GenericHeader)

    describe("a header with no children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local headerType = GenericHeader("test")
			local instance = Roact.mount(Roact.createElement(headerType), folder)

			Roact.unmount(instance)
			folder:Destroy()
        end)

		it("should accept empty tables instead of nil without issue", function()
            local folder = Instance.new("Folder")
            local headerType = GenericHeader("test", {}, {}, {})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

			Roact.unmount(instance)
			folder:Destroy()
        end)

        it("should fill its container by default", function()
			local mockWidth = 182
			local mockHeight = 374

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local headerType = GenericHeader("test")
			local instance = Roact.mount(Roact.createElement(headerType), frame)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth)
			expect(guiObject.AbsoluteSize.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should respect the Size property", function()
			local mockWidth = 182
            local mockHeight = 374
            local newHeight = 100

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local headerType = GenericHeader("test")
			local instance = Roact.mount(Roact.createElement(headerType, {Size = UDim2.new(0.5, 0, 0, newHeight)}), frame)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth / 2)
			expect(guiObject.AbsoluteSize.Y).to.equal(newHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should pass on other Frame properties", function()
            local folder = Instance.new("Folder")

            local position = UDim2.new(0.5, 100, 0.25, 200)
            local color = Color3.fromRGB(50, 100, 150)
            local transparency = 0.25

            local headerType = GenericHeader("test")
            local instance = Roact.mount(Roact.createElement(headerType, {
                Position = position,
                BackgroundColor3 = color,
                BackgroundTransparency = transparency,
            }), folder)

            local frame = folder:FindFirstChildWhichIsA("Frame", true)
            expect(frame.Position).to.equal(position)
            expect(frame.BackgroundColor3).to.equal(color)
            expect(frame.BackgroundTransparency).to.equal(transparency)

			Roact.unmount(instance)
			folder:Destroy()
        end)
	end)

    describe("a header with left children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local left = Roact.createElement("Frame")
            local headerType = GenericHeader("test", {left=left}, {}, {})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local left = folder:FindFirstChild("left", true)
            expect(left).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)
    end)

    describe("a header with right children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local right = Roact.createElement("Frame")
            local headerType = GenericHeader("test", {}, {}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local right = folder:FindFirstChild("right", true)
            expect(right).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)
    end)

    describe("a header with left and right children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local left = Roact.createElement("Frame")
            local right = Roact.createElement("Frame")
            local headerType = GenericHeader("test", {left=left}, {}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local left = folder:FindFirstChild("left", true)
            expect(left).to.be.ok()
            local right = folder:FindFirstChild("right", true)
            expect(right).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)

        it("should fill its container by default", function()
			local mockWidth = 182
			local mockHeight = 374

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local left = Roact.createElement("Frame", {Size = UDim2.new(0, 50, 0, 50)})
            local right = Roact.createElement("Frame", {Size = UDim2.new(0, 50, 0, 50)})

            local headerType = GenericHeader("test", {left=left}, {}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType), frame)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth)
			expect(guiObject.AbsoluteSize.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should respect the Size property", function()
            local mockWidth = 182
            local mockHeight = 374
            local newHeight = 100

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local left = Roact.createElement("Frame", {Size = UDim2.new(0, 50, 0, 50)})
            local right = Roact.createElement("Frame", {Size = UDim2.new(0, 50, 0, 50)})

            local headerType = GenericHeader("test", {left=left}, {}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType, {Size = UDim2.new(0.5, 0, 0, newHeight)}), frame)

			local guiObject = frame:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject.AbsoluteSize.X).to.equal(mockWidth / 2)
			expect(guiObject.AbsoluteSize.Y).to.equal(newHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should use the ElementSpacing to space out elements", function()
            local folder = Instance.new("Folder")

            local elementWidth = 50
            local spacing = 10
            local expectedPosition = elementWidth + spacing

            local left1 = Roact.createElement("Frame", {Size = UDim2.new(0, elementWidth, 0, 50), LayoutOrder = 1})
            local left2 = Roact.createElement("Frame", {Size = UDim2.new(0, elementWidth, 0, 50), LayoutOrder = 2})
            local right = Roact.createElement("Frame", {Size = UDim2.new(0, elementWidth, 0, 50)})

            local headerType = GenericHeader("test", {left1=left1, left2=left2}, {}, {right1=right, right2=right})
            local instance = Roact.mount(Roact.createElement(headerType, {ElementSpacing=spacing}), folder)

            local x1 = folder:FindFirstChild("left1", true).AbsolutePosition.X
            local x2 = folder:FindFirstChild("left2", true).AbsolutePosition.X

            expect(x1).to.equal(0)
            expect(x2).to.equal(expectedPosition)

			Roact.unmount(instance)
			folder:Destroy()
        end)
    end)

    describe("a header with center children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local center = Roact.createElement("Frame")
            local headerType = GenericHeader("test", {}, {center=center}, {})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local center = folder:FindFirstChild("center", true)
            expect(center).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)

        it("should expand the center child to fill the space", function()
			local mockWidth = 182
			local mockHeight = 374

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local center = Roact.createElement("Frame", {Size=UDim2.new(1,0,1,0)})
            local headerType = GenericHeader("test", {}, {center1=center}, {})
            local instance = Roact.mount(Roact.createElement(headerType), frame)

            local center1 = frame:FindFirstChild("center1", true)

            expect(center1.AbsoluteSize.X).to.equal(mockWidth)
            expect(center1.AbsoluteSize.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should resize the center child when the parent is resized", function()
			local mockWidth = 200
			local mockHeight = 300

            local screen = Instance.new("ScreenGui")
			local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)
            frame.Parent = screen

            local center = Roact.createElement("Frame", {Size=UDim2.new(1,0,1,0)})
            local headerType = GenericHeader("test", {}, {center1=center}, {})
            local instance = Roact.mount(Roact.createElement(headerType), frame)

            local center1 = frame:FindFirstChild("center1", true)

            expect(center1.AbsoluteSize.X).to.equal(mockWidth)
            expect(center1.AbsoluteSize.Y).to.equal(mockHeight)

            frame.Size = UDim2.new(0, mockWidth / 2, 0, mockHeight / 3)
            _ = frame.AbsoluteSize  --Force an update of AbsoluteSize

            expect(center1.AbsoluteSize.X).to.equal(mockWidth / 2)
            expect(center1.AbsoluteSize.Y).to.equal(mockHeight / 3)

			Roact.unmount(instance)
			frame:Destroy()
        end)
    end)

    describe("a header with all the children", function()
		it("should mount and unmount without issue", function()
            local folder = Instance.new("Folder")
            local left = Roact.createElement("Frame")
            local center = Roact.createElement("Frame")
            local right = Roact.createElement("Frame")
            local headerType = GenericHeader("test", {left=left}, {center=center}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local left = folder:FindFirstChild("left", true)
            expect(left).to.be.ok()
            local center = folder:FindFirstChild("center", true)
            expect(center).to.be.ok()
            local right = folder:FindFirstChild("right", true)
            expect(right).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)

		it("should mount nested children", function()
            local folder = Instance.new("Folder")
            local child = Roact.createElement("Frame")
            local left = Roact.createElement("Frame", {}, {leftChild = child})
            local center = Roact.createElement("Frame", {}, {centerChild = child})
            local right = Roact.createElement("Frame", {}, {rightChild = child})
            local headerType = GenericHeader("test", {left=left}, {center=center}, {right=right})
			local instance = Roact.mount(Roact.createElement(headerType), folder)

            local leftChild = folder:FindFirstChild("leftChild", true)
            expect(leftChild).to.be.ok()
            local centerChild = folder:FindFirstChild("centerChild", true)
            expect(centerChild).to.be.ok()
            local rightChild = folder:FindFirstChild("rightChild", true)
            expect(rightChild).to.be.ok()

			Roact.unmount(instance)
			folder:Destroy()
        end)

        it("should center the center child between the left and right", function()
			local mockWidth = 500
            local mockHeight = 374

            local leftWidth = 100
            local rightWidth = 50
            local spacing = 10
            local expectedWidth = 500 - 2*leftWidth - 2*spacing

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local left = Roact.createElement("Frame", {Size=UDim2.new(0,leftWidth,1,0)})
            local center = Roact.createElement("Frame", {Size=UDim2.new(1,0,1,0)})
            local right = Roact.createElement("Frame", {Size=UDim2.new(0,rightWidth,1,0)})
            local headerType = GenericHeader("test", {left=left}, {center1=center}, {right=right})
            local instance = Roact.mount(Roact.createElement(headerType, {ElementSpacing=spacing}), frame)

            local center1 = frame:FindFirstChild("center1", true)

            expect(center1.AbsoluteSize.X).to.equal(expectedWidth)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should prevent the center child from setting a negative size", function()
			local mockWidth = 500
            local mockHeight = 374

            local sideWidth = 300

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local left = Roact.createElement("Frame", {Size=UDim2.new(0,sideWidth,1,0)})
            local center = Roact.createElement("Frame", {Size=UDim2.new(1,0,1,0)})
            local right = Roact.createElement("Frame", {Size=UDim2.new(0,sideWidth,1,0)})
            local headerType = GenericHeader("test", {left=left}, {center1=center}, {right=right})
            local instance = Roact.mount(Roact.createElement(headerType), frame)

            local center1 = frame:FindFirstChild("center1", true)

            expect(center1.AbsoluteSize.X).to.equal(0)

			Roact.unmount(instance)
			frame:Destroy()
        end)

        it("should allow the children to set relative heights", function()
			local mockWidth = 500
            local mockHeight = 374

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, mockWidth, 0, mockHeight)

            local left = Roact.createElement("Frame", {Size=UDim2.new(0,50,1,0)})
            local center = Roact.createElement("Frame", {Size=UDim2.new(1,0,1,0)})
            local right = Roact.createElement("Frame", {Size=UDim2.new(0,50,1,0)})
            local headerType = GenericHeader("test", {left1=left}, {center1=center}, {right1=right})
            local instance = Roact.mount(Roact.createElement(headerType), frame)

            local left1 = frame:FindFirstChild("left1", true)
            local center1 = frame:FindFirstChild("center1", true)
            local right1 = frame:FindFirstChild("right1", true)

            expect(left1.AbsoluteSize.Y).to.equal(mockHeight)
            expect(center1.AbsoluteSize.Y).to.equal(mockHeight)
            expect(right1.AbsoluteSize.Y).to.equal(mockHeight)

			Roact.unmount(instance)
			frame:Destroy()
        end)
    end)
end
