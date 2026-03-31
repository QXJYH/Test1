return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
    local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

    local ChannelDetailsHeader = require(script.Parent.ChannelDetailsHeader)

    describe("lifecycle", function()
        it("should mount and unmount without issue", function()
            local _, cleanup = mountStyledFrame(Roact.createElement(ChannelDetailsHeader))

            cleanup()
        end)
    end)

end