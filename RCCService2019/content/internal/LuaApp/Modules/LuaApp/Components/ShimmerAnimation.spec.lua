return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)
	local DarkTheme = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local FFlagLuaAppShimmerOnChinaBuyButton = settings():GetFFlag("LuaAppShimmerOnChinaBuyButton")

	it("should create and destroy without errors in classic theme", function()
		local element = mockServices({
			ShimmerAnimation = Roact.createElement(ShimmerAnimation)
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors in dark theme", function()
		local element = mockServices({
			ShimmerAnimation = Roact.createElement(ShimmerAnimation)
		}, {
			includeThemeProvider = true,
			theme = DarkTheme,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	if FFlagLuaAppShimmerOnChinaBuyButton then
		it("should create and destroy without errors with theme settings passed in", function()
			local element = mockServices({
				ShimmerAnimation = Roact.createElement(ShimmerAnimation, {
					themeSettings = DarkTheme.SystemPrimaryButton,
				})
			}, {
				includeThemeProvider = true,
				theme = DarkTheme,
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end

	it("checking shimmer position", function()
		local element = mockServices({
			ShimmerAnimation = Roact.createElement(ShimmerAnimation,
				{
					Size = UDim2.new(0, 100, 0, 100),
					Position = UDim2.new(0, 0, 0, 0),
					shimmerScale = 2,
					shimmerSpeed = 2,
				})
		}, {
			includeThemeProvider = true,
			theme = DarkTheme,
			includeStyleProvider = false,
			includeLocalizationProvider = false,
		})

		local textureScrollerInstance = nil
		local textureInstance = nil
		local instance = Roact.mount(element)
		textureScrollerInstance = instance._child._child._child._instance
		textureInstance = textureScrollerInstance.imageRef.current

		textureScrollerInstance.renderSteppedCallback(0.3)
		expect(textureInstance.Position.X.Scale).to.be.near(-1.4)
		expect(textureInstance.Position.X.Offset).to.equal(0)
		expect(textureInstance.Position.Y.Scale).to.equal(0.5)
		expect(textureInstance.Position.Y.Offset).to.equal(0)
		textureScrollerInstance.renderSteppedCallback(0.3)
		expect(textureInstance.Position.X.Scale).to.be.near(-0.8)
		expect(textureInstance.Position.X.Offset).to.equal(0)
		expect(textureInstance.Position.Y.Scale).to.equal(0.5)
		expect(textureInstance.Position.Y.Offset).to.equal(0)
		textureScrollerInstance.renderSteppedCallback(0.6)
		expect(textureInstance.Position.X.Scale).to.be.near(0.4)
		expect(textureInstance.Position.X.Offset).to.equal(0)
		expect(textureInstance.Position.Y.Scale).to.equal(0.5)
		expect(textureInstance.Position.Y.Offset).to.equal(0)
		textureScrollerInstance.renderSteppedCallback(0.31)
		expect(textureInstance.Position.X.Scale).to.be.near(-1.98)
		expect(textureInstance.Position.X.Offset).to.equal(0)
		expect(textureInstance.Position.Y.Scale).to.equal(0.5)
		expect(textureInstance.Position.Y.Offset).to.equal(0)
		Roact.unmount(instance)
	end)
end