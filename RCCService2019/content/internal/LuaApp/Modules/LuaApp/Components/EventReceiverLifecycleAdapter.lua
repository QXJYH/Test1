local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

return function(props)
	local receiverComponents = props.receiverComponents
	local robloxEventReceiver = props.RobloxEventReceiver

	local receiverTree = {}
	for idx, receiverComponent in ipairs(receiverComponents) do
		receiverTree[idx] = Roact.createElement(receiverComponent, {
			RobloxEventReceiver = robloxEventReceiver
		})
	end

	return Roact.createElement("Folder", {}, receiverTree)
end
