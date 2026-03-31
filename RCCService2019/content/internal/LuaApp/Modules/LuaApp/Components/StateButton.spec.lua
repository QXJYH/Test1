return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
    local StateButton = require(Modules.LuaApp.Components.StateButton)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(StateButton, {
            Size = UDim2.new(0, 8, 0, 8),
            Image = "LuaApp/icons/ic-ROBUX",
            Disabled = true,
            StateChanged = function()end,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end

