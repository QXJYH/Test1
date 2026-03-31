return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local ChannelScreenSkeleton = require(script.Parent.ChannelScreenSkeleton)

	local Roact = dependencies.Roact

	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	describe("lifecycle", function()
		it("SHOULD mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChannelScreenSkeleton))
			cleanup()
		end)
	end)
end