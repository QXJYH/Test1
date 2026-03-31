return function()
	local ApplyNavigateToRoute = require(script.Parent.ApplyNavigateToRoute)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	it("should assert if given a non-table for route", function()
		ApplyNavigateToRoute({})

		expect(function()
			ApplyNavigateToRoute(nil)
		end).to.throw()

		expect(function()
			ApplyNavigateToRoute("Blargle!")
		end).to.throw()

		expect(function()
			ApplyNavigateToRoute(false)
		end).to.throw()

		expect(function()
			ApplyNavigateToRoute(0)
		end).to.throw()

		expect(function()
			ApplyNavigateToRoute(function() end)
		end).to.throw()
	end)

	if not FFlagLuaNavigationLockRefactor then
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			ApplyNavigateToRoute({}, nil)
			ApplyNavigateToRoute({}, 0)

			expect(function()
				ApplyNavigateToRoute({}, "Blargle!")
			end).to.throw()

			expect(function()
				ApplyNavigateToRoute({}, {})
			end).to.throw()

			expect(function()
				ApplyNavigateToRoute({}, false)
			end).to.throw()

			expect(function()
				ApplyNavigateToRoute({}, function() end)
			end).to.throw()
		end)
	end
end
