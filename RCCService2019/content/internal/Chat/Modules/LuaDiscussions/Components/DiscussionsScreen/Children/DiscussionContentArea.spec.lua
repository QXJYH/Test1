return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
    local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

    local DiscussionContentArea = require(script.Parent.DiscussionContentArea)

    local DUMMY_ICON = "rbxassetid://2610133241"
    local DUMMY_CHANNEL_MODELS = {
        {
            channelId = "1",
            mainText = "hello",
            subText = "general",
        },
        {
            channelId = "2",
            mainText = "howdy",
            subText = "general",
        },
        {
            channelId = "3",
            mainText = "buongiorno",
            subText = "general",
        },
    }

    local DUMMY_DISCUSSION_MODELS = {
        {
            discussionId = "did1",
            discussionIcon = DUMMY_ICON,
            channelModels = DUMMY_CHANNEL_MODELS,
        },
        {
            discussionId = "did2",
            discussionIcon = DUMMY_ICON,
            channelModels = DUMMY_CHANNEL_MODELS,
        },
        {
            discussionId = "did2",
            discussionIcon = DUMMY_ICON,
            channelModels = DUMMY_CHANNEL_MODELS,
        }
    }

    describe("lifecycle", function()
        it("should mount and unmount without issue", function()
            local _, cleanup = mountStyledFrame(Roact.createElement(DiscussionContentArea))

            cleanup()
        end)

        it("should mount and unmount without issue", function()
            local _, cleanup = mountStyledFrame(Roact.createElement(DiscussionContentArea, {
                discussionModels = DUMMY_DISCUSSION_MODELS,
            }))

            cleanup()
        end)
    end)

end