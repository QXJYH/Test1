local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local StateTable = require(Modules.LuaApp.StateTable)

--[[
	StateTableBuilder implements the Builder Pattern to make it easier
	to create new a StateTable without the intricacies of manually
	writing a transition table. Ex:

	local stateTable = StateTableBuilder.new():withName("My State Table")
		:addState("Initial")
			:withEvent("Event1"):nextState("Next"):action(function() ... end)
			:withEvent("Event2"):nextState("Last")
		:addState("Next")
			:withEvent("Event2"):action(function() ... end)
		:addState("Last")
		:build()
]]
local StateTableBuilder = {}
StateTableBuilder.__index = StateTableBuilder

function StateTableBuilder.new()
	local self = { transitionTable = {} }
	setmetatable(self, StateTableBuilder)

	return self
end

function StateTableBuilder:withName(stateTableName)
	assert(typeof(stateTableName) == "string", "stateTableName must be a string")
	assert(#stateTableName > 0, "stateTableName must not be empty")
	assert(self.stateTableName == nil, "Cannot call withName twice")

	self.stateTableName = stateTableName
	return self
end

function StateTableBuilder:withInitialState(initialState)
	assert(typeof(initialState) == "string", "initialState must be a string")
	assert(#initialState > 0, "initialState must not be empty")
	assert(self.initialState == nil, "Cannot call withInitialState twice")

	self.initialState = initialState
	return self
end

function StateTableBuilder:withInitialContext(initialContext)
	assert(typeof(initialContext) == "table", "initialContext must be a table")
	assert(self.initialContext == nil, "Cannot call withInitialContext twice")

	self.initialContext = initialContext
	return self
end

function StateTableBuilder:addState(stateName)
	assert(typeof(stateName) == "string", "stateName must be a string")
	assert(#stateName > 0, "stateName must not be empty")
	assert(self.transitionTable[stateName] == nil, string.format("Cannot add the same state '%s' twice", stateName))

	self.transitionTable[stateName] = {}
	self.currentStateName = stateName
	self.currentEventName = nil
	return self
end

function StateTableBuilder:withEvent(eventName)
	assert(typeof(eventName) == "string", "eventName must be a string")
	assert(#eventName > 0, "eventName must not be empty")
	assert(self.currentStateName ~= nil, "Cannot add an event without first specifying a state via addState()")
	assert(self.transitionTable[self.currentStateName][eventName] == nil,
		"Cannot add an event to the same state more than once")

	self.transitionTable[self.currentStateName][eventName] = {}
	self.currentEventName = eventName
	return self
end

function StateTableBuilder:nextState(stateName)
	assert(typeof(stateName) == "string", "stateName must be a string")
	assert(#stateName > 0, "stateName must not be empty")
	assert(self.currentEventName ~= nil, "Must specify an event before attaching nextState, via withEvent()")
	assert(self.transitionTable[self.currentStateName][self.currentEventName].nextState == nil,
		"Cannot set nextState twice for the same event transition" )

	self.transitionTable[self.currentStateName][self.currentEventName].nextState = stateName
	return self
end

function StateTableBuilder:action(actionFunctor)
	assert(typeof(actionFunctor) == "function", "actionFunctor must be a function")
	assert(self.currentEventName ~= nil, "Must specify an event before attaching action, via withEvent()")
	assert(self.transitionTable[self.currentStateName][self.currentEventName].action == nil,
		"Cannot set action twice for the same event transition" )

	self.transitionTable[self.currentStateName][self.currentEventName].action = actionFunctor
	return self
end

function StateTableBuilder:build()
	assert(self.stateTableName ~= nil and #self.stateTableName > 0, "State table name was not set via withName()")
	assert(self.initialState ~= nil and #self.initialState > 0, "Initial state was not set via withInitialState()")
	assert(typeof(self.transitionTable[self.initialState]) == "table", "Initial state was not added to state table")
	return StateTable.new(self.stateTableName, self.initialState, self.initialContext, self.transitionTable)
end

return StateTableBuilder
