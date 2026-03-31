return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
    local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

    local ImageList = require(script.Parent.ImageList)

    describe("lifecycle", function()
        it("should mount and unmount without issue", function()
            local _, cleanup = mountStyledFrame(Roact.createElement(ImageList))

            cleanup()
        end)
    end)

end