return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local TableUtilities = require(CorePackages.AppTempCommon.LuaApp.TableUtilities)
	local ScreenGuiBlur = require(Modules.LuaApp.Reducers.ScreenGuiBlur)
	local SetScreenGuiBlur = require(Modules.LuaApp.Actions.SetScreenGuiBlur)

	it("should have correct default value", function()
		local defaultState = ScreenGuiBlur(nil, {})

		expect(defaultState).to.be.ok()
		expect(defaultState.hasBlur).to.equal(false)
		expect(defaultState.blurDisplayOrder).to.equal(0)
		expect(type(defaultState.details)).to.equal("table")
		expect(TableUtilities.FieldCount(defaultState.details)).to.equal(0)
	end)

	describe("SetScreenGuiBlur", function()
		it("should preserve purity", function()
			local oldState = ScreenGuiBlur(nil, {})
			local newState = ScreenGuiBlur(oldState, SetScreenGuiBlur(true, 1))
			expect(oldState).to.never.equal(newState)
			expect(oldState.details).to.never.equal(newState.details)
		end)

		it("should set ScreenGuiBlur correctly", function()
			local source1 = "AppRouter"
			local source2 = "AntiAddiction"

			local state1 = ScreenGuiBlur(nil, {})
			local state2 = ScreenGuiBlur(state1, SetScreenGuiBlur(source1, true, 2))
			expect(state2.hasBlur).to.equal(true)
			expect(state2.blurDisplayOrder).to.equal(2)
			expect(TableUtilities.FieldCount(state2.details)).to.equal(1)
			expect(state2.details[source1]).to.equal(2)

			local state3 = ScreenGuiBlur(state2, SetScreenGuiBlur(source1, true, 5))
			expect(state3.hasBlur).to.equal(true)
			expect(state3.blurDisplayOrder).to.equal(5)
			expect(TableUtilities.FieldCount(state3.details)).to.equal(1)
			expect(state3.details[source1]).to.equal(5)

			local state4 = ScreenGuiBlur(state3, SetScreenGuiBlur(source2, true, 10))
			expect(state4.hasBlur).to.equal(true)
			expect(state4.blurDisplayOrder).to.equal(10)
			expect(TableUtilities.FieldCount(state4.details)).to.equal(2)
			expect(state4.details[source1]).to.equal(5)
			expect(state4.details[source2]).to.equal(10)

			local state5 = ScreenGuiBlur(state4, SetScreenGuiBlur(source2, false, 10))
			expect(state5.hasBlur).to.equal(true)
			expect(state5.blurDisplayOrder).to.equal(5)
			expect(TableUtilities.FieldCount(state5.details)).to.equal(1)
			expect(state5.details[source1]).to.equal(5)

			local state6 = ScreenGuiBlur(state5, SetScreenGuiBlur(source1, false, 2))
			expect(state6.hasBlur).to.equal(false)
			expect(state6.blurDisplayOrder).to.equal(0)
			expect(TableUtilities.FieldCount(state6.details)).to.equal(0)
		end)
	end)
end