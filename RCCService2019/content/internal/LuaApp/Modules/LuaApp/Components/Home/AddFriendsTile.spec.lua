return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AddFriendsTile = require(script.Parent.AddFriendsTile)

	it("should create and destroy without errors", function()
		local element = mockServices({
			wrapper = Roact.createElement(AddFriendsTile, {
				thumbnailSize = 80,
				totalWidth = 80,
				totalHeight = 105,
				layoutOrder = 1,
			}),
		}, {
			includeStoreProvider = true,
		})


		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end