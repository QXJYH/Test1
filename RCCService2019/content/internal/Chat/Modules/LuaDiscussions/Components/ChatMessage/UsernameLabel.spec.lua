return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local UsernameLabel = require(script.Parent.UsernameLabel)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(UsernameLabel))

			cleanup()
		end)
	end)

	describe("prop usernameContent", function()
		it("it should display the usernameContent as-is", function()
			local mockUsername = "gollygreg"
			local tree1 = Roact.createElement(UsernameLabel, {
				usernameContent = mockUsername,
			})
			local frame, cleanup = mountStyledFrame(tree1)
			local guiObject1 = frame:FindFirstChildWhichIsA("TextLabel", true)
			expect(guiObject1.Text).to.equal(mockUsername)

			cleanup()
		end)
	end)
end