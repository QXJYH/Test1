return function()

	local CoreGui = game:GetService("CoreGui")

	local Modules = CoreGui.RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)

	local ActionButton = require(Modules.LuaChat.Components.ChatGameCardComponents.ActionButton)


    it("should create and destroy without errors", function()
        local actionButton = Roact.createElement(ActionButton, {})
        local instance = Roact.mount(actionButton)
        Roact.unmount(instance)
    end)

    it("should have its text contained within its image", function()
        local frame = Instance.new("Frame")
        local tree = Roact.createElement(ActionButton, {
            text = "text string"
        })
        local instance = Roact.mount(tree, frame)
        local textLabel = frame:FindFirstChildWhichIsA("GuiObject")

        local frame2 = Instance.new("Frame")
        local tree2 = Roact.createElement(ActionButton, {
            text = "longer text string"
        })
        local instance2 = Roact.mount(tree2, frame2)
        local textLabel2 = frame2:FindFirstChildWhichIsA("GuiObject")

        expect(textLabel.AbsoluteSize.X < textLabel2.AbsoluteSize.X).to.equal(true)
        Roact.unmount(instance)
        Roact.unmount(instance2)

        frame:Destroy()
        frame2:Destroy()
    end)

end