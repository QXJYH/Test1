return function()
	local LuaChat = script.Parent.Parent
	local ToggleChatPaused = require(script.Parent.ToggleChatPaused)
	local ActionToggleChatPaused = require(LuaChat.Actions.ToggleChatPaused)

	local FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults =
		settings():GetFFlag("LuaChatScreenManagerAlwaysUpdatesWithDefaultsV390")

	describe("Action ToggleChatPaused", function()
		it("sets the ToggleChatPaused flag", function()
			local state = ToggleChatPaused(nil, {})

			if FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults then
				expect(state).to.equal(true)
			else
				expect(state).to.equal(false)
			end

			state = ToggleChatPaused(state, ActionToggleChatPaused(false))

			expect(state).to.equal(false)

			state = ToggleChatPaused(state, ActionToggleChatPaused(true))

			expect(state).to.equal(true)
		end)
	end)
end