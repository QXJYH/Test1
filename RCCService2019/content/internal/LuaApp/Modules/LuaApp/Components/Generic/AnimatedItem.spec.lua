return function()
	local AnimatedItem = require(script.Parent.AnimatedItem)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)

	describe("AnimatedItem", function()
		it("should create/destroy/update without errors", function()
			local element = Roact.createElement(AnimatedItem.AnimatedFrame, {
				animatedProps = {
					[AnimatedItem.AnimatedProp.Size.Offset.Y] = 100,
				},
			})

			local instance = Roact.mount(element)

			Roact.reconcile(instance, Roact.createElement(AnimatedItem.AnimatedFrame, {
				animatedProps = {
					[AnimatedItem.AnimatedProp.Size.Offset.Y] = 200,
				},
			}))

			Roact.unmount(instance)
		end)
	end)
end
