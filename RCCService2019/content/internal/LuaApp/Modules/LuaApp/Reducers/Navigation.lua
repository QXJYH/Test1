local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Rodux = require(Modules.Common.Rodux)
local Immutable = require(Modules.Common.Immutable)
local Cryo = require(CorePackages.Cryo)
local ApplyNavigateToRoute = require(Modules.LuaApp.Actions.ApplyNavigateToRoute)
local ApplyNavigateBack = require(Modules.LuaApp.Actions.ApplyNavigateBack)
local ApplyResetNavigationHistory = require(Modules.LuaApp.Actions.ApplyResetNavigationHistory)
local ApplyNavigateUp = require(Modules.LuaApp.Actions.ApplyNavigateUp)
local ApplySetNavigationLocked = require(Modules.LuaApp.Actions.ApplySetNavigationLocked)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

local function getDefaultRoute()
	return { { name = FlagSettings.GetDefaultAppPage() } }
end

if FFlagLuaNavigationLockRefactor then
	return Rodux.createReducer({
		history = { getDefaultRoute() },
		lockNavigationActions = false,
	}, {
		[ApplyNavigateToRoute.name] = function(state, action)
			if not action.bypassNavigationLock and state.lockNavigationActions then
				return state
			end

			local newState = Cryo.Dictionary.join(state, {
				history = #action.route == 1 and
					{ action.route } or
					Cryo.List.join(state.history, { action.route }),
				lockNavigationActions = true,
			})

			return newState
		end,
		[ApplyNavigateBack.name] = function(state, action)
			if not action.bypassNavigationLock and state.lockNavigationActions then
				return state
			end

			local newState = state
			if #state.history > 1 then
				newState = Cryo.Dictionary.join(state, {
					history = Cryo.List.removeIndex(state.history, #state.history),
					lockNavigationActions = true,
				})
			end

			return newState
		end,
		[ApplyNavigateUp.name] = function(state, action)
			if not action.bypassNavigationLock and state.lockNavigationActions then
				return state
			end

			local newState

			local currentRoute = state.history[#state.history]
			if #currentRoute == 1 then
				newState = Cryo.Dictionary.join(state, {
					history = Cryo.List.join(state.history, { getDefaultRoute() }),
					lockNavigationActions = true,
				})
			else
				local truncatedRoute = Cryo.List.removeIndex(currentRoute, #currentRoute)
				newState = Cryo.Dictionary.join(state, {
					history = Cryo.List.join(state.history, { truncatedRoute }),
					lockNavigationActions = true,
				})
			end

			return newState
		end,
		[ApplyResetNavigationHistory.name] = function(state, action)
			local newState = Cryo.Dictionary.join(state, {
				history = { action.route or getDefaultRoute() },
				lockNavigationActions = true,
			})

			return newState
		end,
		[ApplySetNavigationLocked.name] = function(state, action)
			if state.lockNavigationActions == action.locked then
				return state
			end

			local newState = Cryo.Dictionary.join(state, {
				lockNavigationActions = action.locked or false,
			})

			return newState
		end,
	})
else
	local function calcNewLockTimer(oldTime, newTime)
		-- If the new time is 0, we reset the timer
		if newTime == 0 then
			return 0
		end
		-- If the new time is nil, then we're not setting the time and the old time stays
		if newTime == nil then
			return oldTime
		end
		-- Otherwise we need to take whichever time is later (i.e. further in the future)
		return math.max(newTime, oldTime)
	end

	return Rodux.createReducer({
		history = { getDefaultRoute() },
		lockTimer = 0,
	}, {
		[ApplyNavigateToRoute.name] = function(state, action)
			return Immutable.JoinDictionaries(state, {
				history = #action.route == 1 and
					{ action.route } or
					Immutable.Append(state.history, action.route),
				lockTimer = calcNewLockTimer(state.lockTimer, action.timeout),
			})
		end,
		[ApplyNavigateBack.name] = function(state, action)
			if #state.history > 1 then
				state = Immutable.JoinDictionaries(state, {
					history = Immutable.RemoveFromList(state.history, #state.history),
					lockTimer = calcNewLockTimer(state.lockTimer, action.timeout),
				})
			end
			return state
		end,
		[ApplyResetNavigationHistory.name] = function(state, action)
			return {
				history = { action.route or getDefaultRoute() },
				lockTimer = state.lockTimer,
			}
		end,
	})
end
