return function()
	local NetworkThunk = require(script.Parent.NetworkThunk)
	local UrlBuilder = require(script.Parent.UrlBuilder)

	local mockApi = {}
	local mockNetworkImpl = {}
	local mockUrl = UrlBuilder:new("testUrl")

	describe("NetworkThunk.GET", function()
		it("SHOULD return a thunk", function()
			local result = NetworkThunk.GET(mockApi, mockNetworkImpl, mockUrl)
			expect(type(result)).to.equal("function")
		end)
	end)
end