return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)

	local screenSize = Vector2.new(100, 100)
	local guiInset = {
		left = 10,
		top = 5,
		right = 10,
		bottom = 5,
	}

	describe("getSafeAreaSize", function()
		it("should return SafeAreaSize with proper screenSize and guiInset", function()
			local safeAreaSize = getSafeAreaSize(screenSize, guiInset)
			expect(safeAreaSize.X.Offset).to.equal(80)
			expect(safeAreaSize.Y.Offset).to.equal(90)
		end)

		it("should throw with negative safeAreaSize", function()
			expect(function()
				getSafeAreaSize(Vector2.new(0, 100), guiInset)
			end).to.throw()

			expect(function()
				getSafeAreaSize(Vector2.new(100, 0), guiInset)
			end).to.throw()
		end)

		it("should throw with invalid screenSize", function()
			expect(function()
				getSafeAreaSize(nil, guiInset)
			end).to.throw()

			expect(function()
				getSafeAreaSize(true, guiInset)
			end).to.throw()

			expect(function()
				getSafeAreaSize(0, guiInset)
			end).to.throw()

			expect(function()
				getSafeAreaSize("", guiInset)
			end).to.throw()

			expect(function()
				getSafeAreaSize({}, guiInset)
			end).to.throw()
		end)

		it("should throw with invalid guiInset", function()
			expect(function()
				getSafeAreaSize(screenSize, nil)
			end).to.throw()

			expect(function()
				getSafeAreaSize(screenSize, true)
			end).to.throw()

			expect(function()
				getSafeAreaSize(screenSize, 0)
			end).to.throw()

			expect(function()
				getSafeAreaSize(screenSize, "")
			end).to.throw()

			expect(function()
				getSafeAreaSize(screenSize, {})
			end).to.throw()
		end)
	end)
end