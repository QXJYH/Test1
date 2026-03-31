local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local App = require(script.Parent.ExampleApp)

return function(test)
	local app = Roact.createElement(App)
	local instance = Roact.mount(app, CoreGui, "ExampleApp")

	local success, result = pcall(test)

	Roact.unmount(instance)
	if not success then
		error(result)
	end
end