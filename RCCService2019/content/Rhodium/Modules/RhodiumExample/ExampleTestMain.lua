local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")

local TestEZ = require(CorePackages.TestEZ)
local TestBootstrap = TestEZ.TestBootstrap

local TextReporter = TestEZ.Reporters.TextReporter

local Tests = script.Parent.Tests

local Rhodium = game.CoreGui.RobloxGui.Modules.Rhodium
local RhodiumExtraEnvironment = {
	Element = require(Rhodium.Element),
	XPath = require(Rhodium.XPath),
	VirtualInput = require(Rhodium.VirtualInput),
}

local function runTest()
	TestBootstrap:run({Tests}, TextReporter, {
		noXpcallByDefault = true,
		extraEnvironment = {
			Rhodium = RhodiumExtraEnvironment,
		}
	})
end

return function()
	UserInputService.InputEnded:connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.Keyboard and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
		then
			if inputObject.KeyCode == Enum.KeyCode.R then
				runTest()
			end
		end
	end)
end