return function()
	local verticalLayout = require(script.Parent.verticalLayout)

	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	describe("WHEN given an array", function()
		local folder = Instance.new("Folder")
		local block = verticalLayout({})
		local tree = Roact.createElement("Folder", nil, block)
		Roact.mount(tree, folder)

		it("SHOULD return a tree with a UIListLayout with Vertical FillDirection", function()
			local layout = folder:FindFirstChildWhichIsA("UIListLayout", true)
			expect(layout).to.be.ok()
			expect(layout.FillDirection).to.equal(Enum.FillDirection.Vertical)
		end)
	end)
end