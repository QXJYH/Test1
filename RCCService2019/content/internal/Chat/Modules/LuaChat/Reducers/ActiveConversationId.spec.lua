return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local LuaChat = Modules.LuaChat

	local ActiveConversationId = require(LuaChat.Reducers.ActiveConversationId)

	local SetRoute = require(LuaChat.Actions.SetRoute)

	describe("initial state", function()
		it("SHOULD return nil when passed nil", function()
			local state = ActiveConversationId(nil, {})
			expect(state).to.never.be.ok()
		end)
	end)

	describe("SetRoute", function()
		it("SHOULD take the conversationId parameter when passed", function()
			local conversationId = "1337"
			local state = ActiveConversationId(nil, SetRoute("", {
				conversationId = conversationId,
			}))
			expect(state).to.equal(conversationId)
		end)

		it("SHOULD return nil when conversationId is not passed", function()
			expect(ActiveConversationId(nil, SetRoute("", {}))).to.never.be.ok()
		end)

		it("SHOULD wipe the state of the reducer when converastionId is not passed again", function()
			local conversationId = "1337"
			local firstState = ActiveConversationId(nil, SetRoute("1", {
				conversationId = conversationId,
			}))
			expect(firstState).to.equal(conversationId)

			local secondState = ActiveConversationId(firstState, SetRoute("2"))
			expect(secondState).to.equal(nil)
		end)
	end)
end