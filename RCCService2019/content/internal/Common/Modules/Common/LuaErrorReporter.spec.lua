return function()
	-- NOTE : since each Lua Error Reporter object adds an observer to the script context,
	-- it is important that tests clean up after themselves and call the delete() function
    local LuaErrorReporter = require(script.Parent.LuaErrorReporter)
	local Signal = require(script.Parent.Signal)

	local FFlagLuaAppEnableErrorReporterRateLimit = settings():GetFFlag("LuaAppEnableErrorReporterRateLimit")

	-- create some dummy test values
	local testError = "foo"
	local testAppName = "testSuite"
	local testSignal = Signal.new()

	local function createSilentLER(rateLimitIntervalSec)
		-- NOTE - creating this reporter with the testSignal circumvents testing the functionality
		-- of observing the ScriptContext.Error signal. It is assumed that the Error signal just works.

		-- NOTE - even if the handleError() function doesn't get overriden on the LuaErrorReporter,
		-- don't send error reports over the wire for unit tests
		local ler = LuaErrorReporter.new(testSignal, rateLimitIntervalSec)
		ler._verbose = false
		ler._shouldReportInflux = false
		ler._shouldReportGoogleAnalytics = false
		ler._shouldReportDiag = false
		return ler
	end
	local function fireTestErrorSignal()
		-- fire a signal that mimics the structure of the ScriptContext.Error's arguments:
		-- (message, stackTrace, scriptSource)
		testSignal:fire(testError, debug.traceback(), script)

		-- NOTE - if these tests are ever to be modified to once again observe
		-- the ScriptContext.Error signal, then be mindful that testSignal resolves synchronously
		-- while ScriptContext.Error does not.
	end

    describe("new()", function()
		it("should construct with a custom signal", function()
			local ler = createSilentLER()
			expect(ler).to.be.ok()

			ler:delete()
		end)

		it("should create an object that observes errors", function()
			local callCounter = 0

			local ler = createSilentLER()
			function ler:handleError(message, stack, offendingScript)
				callCounter = callCounter + 1
				expect(message).to.be.ok()
				expect(stack).to.be.ok()
				expect(offendingScript).to.be.ok()
			end

			fireTestErrorSignal()

			ler:delete()

			expect(callCounter).to.equal(1)
		end)
	end)

	describe("delete()", function()
		it("should break the connection to the error context", function()
			local ler = createSilentLER()
			function ler:handleError(message, stack, script)
				error("delete() failed to remove the script context's error observer")
			end

			ler:delete()

			fireTestErrorSignal()
		end)
	end)

	describe("setCurrentApp()", function()
		it("should not allow the value to be nil", function()
			local ler = createSilentLER()

			expect(function()
				ler:setCurrentApp(nil)
			end).to.throw()

			ler:delete()
		end)

		it("should allow the value to be set to a string", function()
			local ler = createSilentLER()

			ler:setCurrentApp(testAppName)
			expect(ler._currentApp).to.equal(testAppName)

			ler:delete()
		end)
	end)

	describe("handleError()", function()
		it("should be overrideable with a custom function", function()
			local callCounter = 0

			local ler = createSilentLER()
			function ler:handleError(messsage, stack, script)
				callCounter = callCounter + 1
			end

			fireTestErrorSignal()

			expect(callCounter).to.equal(1)
			ler:delete()
		end)
	end)

	describe("rate limiting", function()
		it("should return false for _processErrorForRateLimiting if request is not rate limited", function()
			local ler = createSilentLER()
			ler._rateLimitingThreshold = 2

			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(false)

			ler:delete()
		end)

		it("should return true for _processErrorForRateLimiting if request is rate limited", function()
			local ler = createSilentLER()
			ler._rateLimitingThreshold = 2

			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(false)
			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(false)
			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(true)

			ler:delete()
		end)

		it("should roll off from RATE_LIMIT_CEILING after twice the interval has passed", function()
			local ler = createSilentLER()
			ler._rateLimitingThreshold = 2

			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processRateLimitingTick()
			ler:_processRateLimitingTick()

			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(false)
			ler:delete()
		end)

		it("should still rate limit after one interval if we've reached RATE_LIMIT_CEILING", function()
			local ler = createSilentLER()

			ler._rateLimitingThreshold = 2
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processRateLimitingTick()

			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(true)
			ler:delete()
		end)

		it("should not rate limit if we drop below threshold after interval tick", function()
			local ler = createSilentLER(10)

			ler._rateLimitingThreshold = 2
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processErrorForRateLimiting("msg", "stack")
			ler:_processRateLimitingTick()

			expect(ler:_processErrorForRateLimiting("msg", "stack")).to.equal(false)
			ler:delete()
		end)
	end)

	if FFlagLuaAppEnableErrorReporterRateLimit then
		describe("rate limiting timer tests", function()
			HACK_NO_XPCALL() -- necessary to allow us to wait() for heartbeat timer

			it("should trigger _processRateLimitingTick after tick time", function()
				local ler = createSilentLER(0.05)
				ler._rateLimitingThreshold = 2

				local called = false
				ler._processRateLimitingTick = function()
					called = true
					return false
				end

				expect(called).to.equal(false)

				local totalWaitTime = 0
				while called ~= true do
					expect(totalWaitTime < 0.5).to.equal(true)

					local waitTime = wait(0)
					totalWaitTime = totalWaitTime + waitTime
				end
			end)
		end)
	end
end
