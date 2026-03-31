local CorePackages = game:GetService("CorePackages")
local RunService = game:GetService("RunService")
local Roact = require(CorePackages.Roact)


local FrameRateManager = Roact.Component:extend("FrameRateManager")

function FrameRateManager:render()
	return nil
end

function FrameRateManager:didMount()
	RunService:setThrottleFramerateEnabled(true)
end

function FrameRateManager:willUnmount()
	RunService:setThrottleFramerateEnabled(false)
end

return FrameRateManager

