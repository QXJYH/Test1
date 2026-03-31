return function()
	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
	local dependencies = require(LuaDiscussions.dependencies)
	local Roact = dependencies.Roact
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local ChannelMessage = require(script.Parent.ChannelMessage)

	describe("lifecycle", function()
		it("should mount and unmount without issue", function()
			local _, cleanup = mountStyledFrame(Roact.createElement(ChannelMessage))

			cleanup()
		end)
	end)

	describe("prop LayoutOrder", function()
		it("should set the top level GuiObject LayoutOrder", function()
			local mockLayoutOrder = 100
			local tree = Roact.createElement(ChannelMessage, {
				LayoutOrder = mockLayoutOrder,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local guiObject = folder:FindFirstChildWhichIsA("GuiObject", true)
			expect(guiObject).to.be.ok()
			expect(guiObject.LayoutOrder).to.equal(mockLayoutOrder)

			cleanup()
		end)
	end)

	describe("prop isIncoming", function()
		describe("element usernameRow", function()
			it("should render usernameRow only if isIncoming is true", function()
				local tree = Roact.createElement(ChannelMessage, {
					isIncoming = true,
				})
				local folder, cleanup = mountStyledFrame(tree)

				local usernameRowInstance = folder:FindFirstChild("usernameRow", true)
				expect(usernameRowInstance).to.be.ok()

				cleanup()
			end)

			it("should not render usernameRow only if isIncoming is false", function()
				local tree = Roact.createElement(ChannelMessage, {
					isIncoming = false,
				})
				local folder, cleanup = mountStyledFrame(tree)

				local usernameRowInstance = folder:FindFirstChild("usernameRow", true)
				expect(usernameRowInstance).to.never.be.ok()

				cleanup()
			end)
		end)

		describe("element innerFlexContainer", function()
			it("should render innerFlexContainer with HorizontalAlignment Left when isIncoming is true", function()
				local tree = Roact.createElement(ChannelMessage, {
					isIncoming = true,
				})
				local folder, cleanup = mountStyledFrame(tree)

				local innerFlexContainerInstance = folder:FindFirstChild("innerFlexContainer", true)
				expect(innerFlexContainerInstance).to.be.ok()
				local innerFlexContainerLayoutInstance = innerFlexContainerInstance:FindFirstChild("layout", true)
				expect(innerFlexContainerLayoutInstance).to.be.ok()
				expect(innerFlexContainerLayoutInstance.HorizontalAlignment).to.equal(Enum.HorizontalAlignment.Left)

				cleanup()
			end)

			it("should render innerFlexContainer with HorizontalAlignment Right when isIncoming is false", function()
				local tree = Roact.createElement(ChannelMessage, {
					isIncoming = false,
				})
				local folder, cleanup = mountStyledFrame(tree)

				local innerFlexContainerInstance = folder:FindFirstChild("innerFlexContainer", true)
				expect(innerFlexContainerInstance).to.be.ok()
				local innerFlexContainerLayoutInstance = innerFlexContainerInstance:FindFirstChild("layout", true)
				expect(innerFlexContainerLayoutInstance).to.be.ok()
				expect(innerFlexContainerLayoutInstance.HorizontalAlignment).to.equal(Enum.HorizontalAlignment.Right)

				cleanup()
			end)
		end)
	end)

	describe("prop usernameContent", function()
		it("should set the usernameRow TextLabel Text if the message isIncoming", function()
			local mockUserName = "aportner"
			local tree = Roact.createElement(ChannelMessage, {
				isIncoming = true,
				usernameContent = mockUserName,
			})
			local folder, cleanup = mountStyledFrame(tree)

			local usernameLabelInstance = folder:FindFirstChild("usernameLabel", true)
			expect(usernameLabelInstance).to.be.ok()

			local textLabelInstance = usernameLabelInstance:FindFirstChildWhichIsA("TextLabel", true)
			expect(textLabelInstance.Text).to.equal(mockUserName)

			cleanup()
		end)
	end)

	describe("prop channelMessage", function()
		describe("WHEN given a channelMessage", function()
			local zeroChunkChildrenCount
			do
				-- Mount and count children when given 0 channelMessages
				-- Will compare this later
				local tree = Roact.createElement(ChannelMessage, {
					channelMessage = {}
				})
				local folder, cleanup = mountStyledFrame(tree)
				local innerFlexContainerInstance = folder:FindFirstChild("innerFlexContainer", true)
				local children = innerFlexContainerInstance:GetChildren()

				-- We may have some UILayout objects that live here naturally
				zeroChunkChildrenCount = #children

				cleanup()
			end

			it("SHOULD render 1 chunk", function()
				-- Give the ChannelMessage a single chunk
				local tree = Roact.createElement(ChannelMessage, {
					channelMessage = {
						id = 1,
						chunks = {
							{
								type = "Text",
								message = "hi",
							},
						},
					}
				})
				local folder, cleanup = mountStyledFrame(tree)

				local innerFlexContainerInstance = folder:FindFirstChild("innerFlexContainer", true)
				local children = innerFlexContainerInstance:GetChildren()

				expect(#children).to.equal(zeroChunkChildrenCount + 1)

				cleanup()
			end)

			it("SHOULD render 3 chunks", function()
				-- Give the ChannelMessage a multiple unique chunks
				local tree = Roact.createElement(ChannelMessage, {
					channelMessage = {
						id = 1,
						chunks = {
							{
								type = "Text",
								message = "hi",
							},
							{
								type = "Text",
								message = "hi",
							},
							{
								type = "Text",
								message = "hi",
							},
						},
					}
				})
				local folder, cleanup = mountStyledFrame(tree)

				local innerFlexContainerInstance = folder:FindFirstChild("innerFlexContainer", true)
				local children = innerFlexContainerInstance:GetChildren()

				expect(#children).to.equal(zeroChunkChildrenCount + 3)

				cleanup()
			end)
		end)
	end)

	describe("method getChunkHorizontalAlignmentFrom", function()
		it("should return HorizontalAlignment Left if isIncoming is true", function()
			local result = ChannelMessage.getChunkHorizontalAlignmentFrom({
				isIncoming = true,
			})
			expect(result).to.equal(Enum.HorizontalAlignment.Left)
		end)

		it("should return HorizontalAlignment Right if isIncoming is true", function()
			local result = ChannelMessage.getChunkHorizontalAlignmentFrom({
				isIncoming = false,
			})
			expect(result).to.equal(Enum.HorizontalAlignment.Right)
		end)
	end)

	describe("method getAvatarWidthFrom", function()
		it("should return non-zero if isIncoming is true", function()
			local result = ChannelMessage.getAvatarWidthFrom({
				isIncoming = true,
			})
			expect(result).to.never.equal(0)
		end)

		it("should return zero if isIncoming is true", function()
			local result = ChannelMessage.getAvatarWidthFrom({
				isIncoming = false,
			})
			expect(result).to.equal(0)
		end)
	end)
end