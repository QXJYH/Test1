return function()
	local CoreGui = game:GetService("CoreGui")
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = CoreGui.RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local OpenCentralOverlayForPlacesList = require(Modules.LuaApp.Thunks.OpenCentralOverlayForPlacesList)
	local Game = require(Modules.LuaApp.Models.Game)

	local CentralOverlay = require(Modules.LuaApp.Components.CentralOverlay)

	local function mockStore()
		return MockStore.new({
			ScreenSize = Vector2.new(100, 100),
			GlobalGuiInset = {
				left = 10,
				top = 5,
				right = 10,
				bottom = 5,
			},
		})
	end

	it("should create and destroy without errors", function()
		local store = mockStore()

		local element = mockServices({
			CentralOverlay = Roact.createElement(CentralOverlay),
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	describe("overlay behavior", function()
		it("should not render anything when unrecognized overlay type was set in the store.", function()
			local store = mockStore()

			local element = mockServices({
				CentralOverlay = Roact.createElement(CentralOverlay),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local instance = Roact.mount(element)

			local coreGuiChildren = CoreGui:GetChildren()
			local overlayCount = 0
			for _, child in pairs(coreGuiChildren) do
				if string.find(child.Name, "PortalUIForOverlay") then
					overlayCount = overlayCount + 1
				end
			end

			expect(overlayCount).to.equal(0)

			Roact.unmount(instance)
			store:destruct()
		end)

		it("should render when overlay type is PlacesList", function()
			local store = mockStore()

			local element = mockServices({
				CentralOverlay = Roact.createElement(CentralOverlay),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local instance = Roact.mount(element)

			store:dispatch(OpenCentralOverlayForPlacesList(Game.mock(), Vector2.new(10, 10), Vector2.new(0, 0)))
			store:flush()

			local coreGuiChildren = CoreGui:GetChildren()
			local overlayCount = 0
			for _, child in pairs(coreGuiChildren) do
				if string.find(child.Name, "PortalUIForOverlay") then
					overlayCount = overlayCount + 1
				end
			end

			expect(overlayCount).to.equal(1)

			Roact.unmount(instance)
			store:destruct()
		end)
	end)

end