return function()
	local ApplyResetNavigationHistory = require(script.Parent.ApplyResetNavigationHistory)
	local TableUtilities = require(script.Parent.Parent.TableUtilities)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()
	if not FFlagLuaNavigationLockRefactor then
		return
	end

	it("should throw for invalid route arg", function()
		expect(function()
			ApplyResetNavigationHistory("")
		end).to.throw()

		expect(function()
			ApplyResetNavigationHistory(5)
		end).to.throw()
	end)

	it("should return table with route arg", function()
		local route = { "myroute" }
		local result = ApplyResetNavigationHistory(route)
		expect(result.route).to.equal(route)
		expect(TableUtilities.FieldCount(result)).to.equal(2)
		expect(result.type).to.equal(ApplyResetNavigationHistory.name)
	end)

	it("should return table with nil route arg when none is provided", function()
		local result = ApplyResetNavigationHistory()
		expect(result.route).to.equal(nil)
		expect(TableUtilities.FieldCount(result)).to.equal(1)
		expect(result.type).to.equal(ApplyResetNavigationHistory.name)
	end)
end
