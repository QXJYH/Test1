return function()
	local ApplyNavigateBack = require(script.Parent.ApplyNavigateBack)
	local TableUtilities = require(script.Parent.Parent.TableUtilities)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

	if FFlagLuaNavigationLockRefactor then
		it("should return an appropriate action table", function()
			local result = ApplyNavigateBack()
			expect(TableUtilities.FieldCount(result)).to.equal(1)
			expect(result.type).to.equal(ApplyNavigateBack.name)
		end)
	else
		it("should assert if given a non-nil non-number for navLockEndTime", function()
			ApplyNavigateBack(nil)
			ApplyNavigateBack(0)

			expect(function()
				ApplyNavigateBack("Blargle!")
			end).to.throw()

			expect(function()
				ApplyNavigateBack({})
			end).to.throw()

			expect(function()
				ApplyNavigateBack(false)
			end).to.throw()

			expect(function()
				ApplyNavigateBack(function() end)
			end).to.throw()
		end)
	end
end
