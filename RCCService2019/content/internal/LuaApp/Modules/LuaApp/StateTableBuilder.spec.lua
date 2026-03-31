return function()
	local CoreGui = game:GetService("CoreGui")
	local Modules = CoreGui.RobloxGui.Modules
	local TableUtilities = require(Modules.LuaApp.TableUtilities)
	local StateTableBuilder = require(Modules.LuaApp.StateTableBuilder)

	local TEST_STATE_TABLE_NAME = "test_name"
	local TEST_INITIAL_CONTEXT = { foo = 1 }
	local TEST_STATE_NAME_1 = "test_state_name_1"
	local TEST_STATE_NAME_2 = "test_state_name_2"
	local TEST_EVENT_NAME_1 = "test_event_name_1"
	local TEST_EVENT_NAME_2 = "test_event_name_2"

	describe("StateTableBuilder", function()
		it("should assert when trying to build with no data", function()
			local builder = StateTableBuilder.new()
			expect(function()
				builder:build()
			end).to.throw()
		end)

		it("should assert when trying to build with name but no states", function()
			local builder = StateTableBuilder.new():withName(TEST_STATE_TABLE_NAME)
			expect(function()
				builder:build()
			end).to.throw()
		end)

		it("should assert when trying to build with states but no name", function()
			local builder = StateTableBuilder.new():addState("Initial")
			expect(function()
				builder:build()
			end).to.throw()
		end)

		it("should assert when trying to build without initialState", function()
			local builder = StateTableBuilder.new()
				:withName(TEST_STATE_TABLE_NAME)
				:addState("Initial")
			expect(function()
				builder:build()
			end).to.throw()
		end)

		it("should assert when trying to add an event without a tracked state", function()
			local builder = StateTableBuilder.new():withName(TEST_STATE_TABLE_NAME)
			expect(function()
				builder:withEvent(TEST_EVENT_NAME_1)
			end).to.throw()
		end)

		it("should assert when trying to add a nextState without a tracked event", function()
			local builder = StateTableBuilder.new():withName(TEST_STATE_TABLE_NAME):addState(TEST_STATE_NAME_1)
			expect(function()
				builder:nextState(TEST_STATE_NAME_2)
			end).to.throw()
		end)

		it("should assert when trying to add an action without a tracked event", function()
			local builder = StateTableBuilder.new():withName(TEST_STATE_TABLE_NAME):addState(TEST_STATE_NAME_1)
			expect(function()
				builder:action(function() end)
			end).to.throw()
		end)

		it("should assert when trying to add a non-function action", function()
			local builder = StateTableBuilder.new():withName(TEST_STATE_TABLE_NAME)
				:addState(TEST_STATE_NAME_1)
					:withEvent(TEST_EVENT_NAME_1)

			expect(function()
				builder:action(5)
			end).to.throw()
		end)

		it("should assert when trying to set a non-string initial state", function()
			expect(function()
				StateTableBuilder.new():withInitialState(5)
			end).to.throw()
		end)

		it("should assert when trying to set a non-table initial context", function()
			expect(function()
				StateTableBuilder.new():withInitialContext(5)
			end).to.throw()
		end)

		it("should build a working state table", function()
			local action1Called, action2Called
			local testAction1 = function() action1Called = true end
			local testAction2 = function() action2Called = true end

			local stateTable = StateTableBuilder.new()
				:withName(TEST_STATE_TABLE_NAME)
				:withInitialState(TEST_STATE_NAME_1)
				:withInitialContext(TEST_INITIAL_CONTEXT)
				:addState(TEST_STATE_NAME_1)
					:withEvent(TEST_EVENT_NAME_1):nextState(TEST_STATE_NAME_2):action(testAction1)
				:addState(TEST_STATE_NAME_2)
					:withEvent(TEST_EVENT_NAME_2):nextState(TEST_STATE_NAME_1):action(testAction2)
				:build()

			expect(TableUtilities.FieldCount(stateTable.events)).to.equal(2)

			stateTable.events.test_event_name_1(nil)
			stateTable.events.test_event_name_2(nil)

			expect(action1Called).to.equal(true)
			expect(action2Called).to.equal(true)
		end)
	end)
end
