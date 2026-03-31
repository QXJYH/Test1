local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelScreenSkeleton = require(Components.ChannelScreen.ChannelScreenSkeleton)

return function(target)
	local screenSize = Vector3.new(320, 480)

	local message1 = {
		id = "message1",
		created = "2001",
		chunks = {
			{
				type = "PlainText",
				message = "Hello there",
			}
		},
	}
	local message2 = {
		id = "message2",
		created = "2002",
		chunks = {
			{
				type = "PlainText",
				message = "How are you doing?",
			}
		},
	}
	local message3 = {
		id = "message3",
		created = "2003",
		chunks = {
			{
				type = "PlainText",
				message = "This is a longer message that will span at least two lines.",
			}
		},
	}

	local tree = Roact.createElement("Frame", {
		Size = UDim2.new(0, screenSize.X, 0, screenSize.Y)
	}, {
		channelScreen = Roact.createElement(ChannelScreenSkeleton, {
			channelMessages = {
				message1, message2, message3,
			},
			fullScreenWidth = screenSize.X,
		}),
	})

	local handle = Roact.mount(tree, target, "preview")

	return function()
		Roact.unmount(handle)
	end
end