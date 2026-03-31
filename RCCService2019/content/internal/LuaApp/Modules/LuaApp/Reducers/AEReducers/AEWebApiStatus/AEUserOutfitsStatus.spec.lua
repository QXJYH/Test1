return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AEUserOutfitsStatus = require(script.Parent.AEUserOutfitsStatus)
    local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local AEUserOutfitsStatusAction = require(Modules.LuaApp.Actions.AEActions.AEWebApiStatus.AEUserOutfitsStatus)
	local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)

	local function countChildObjects(aTable)
		local numChildren = 0
		for _ in pairs(aTable) do
			numChildren = numChildren + 1
		end

		return numChildren
	end

	it("should be empty by default", function()
		local status = AEUserOutfitsStatus(nil, {})

		expect(type(status)).to.equal("table")
		expect(countChildObjects(status)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AEUserOutfitsStatus(nil, {})
		local newState = AEUserOutfitsStatus(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should preserve purity", function()
		local key = AEConstants.PRESET_COSTUMES
		local oldState = AEUserOutfitsStatus(nil, {})
		local newState = AEUserOutfitsStatus(oldState, AEUserOutfitsStatusAction(RetrievalStatus.Fetching, key))
		expect(oldState[key]).to.never.equal(newState[key])
	end)

	it("should change retrieval status with the correct action", function()
		local key = AEConstants.PRESET_COSTUMES
		local oldState = AEUserOutfitsStatus(nil, {})
		local newState = AEUserOutfitsStatus(oldState, AEUserOutfitsStatusAction(RetrievalStatus.Fetching, key))
		expect(newState[key]).to.equal(RetrievalStatus.Fetching)

		newState = AEUserOutfitsStatus(newState, AEUserOutfitsStatusAction(RetrievalStatus.Failed, key))
		expect(newState[key]).to.equal(RetrievalStatus.Failed)

		newState = AEUserOutfitsStatus(newState, AEUserOutfitsStatusAction(RetrievalStatus.Done, key))
		expect(newState[key]).to.equal(RetrievalStatus.Done)
	end)
end