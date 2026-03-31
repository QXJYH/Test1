--[[
	Creates a Roact wrapper for a generic image set button that has a loading state.
	Props in addition to ImageSetButton:
		Loading : bool is the button loading. If loading, the button will be disabled and have shimmer animation playing.
]]
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local StateButton = require(Modules.LuaApp.Components.StateButton)

local LoadableButton = Roact.PureComponent:extend("LoadableButton")

function LoadableButton:render()
	local props = self.props
	local newProps = Immutable.RemoveFromDictionary(props, Roact.Children, "Loading")
	local loading = props.Loading
	local disabled = props.Disabled or loading
	newProps.Disabled = disabled
	newProps.AutoButtonColor = false
	local loadingShimmer
	if loading then
		loadingShimmer = Roact.createElement(ShimmerAnimation, {
			Size = UDim2.new(1, 0, 1, 0),
		})
	end
	return Roact.createElement(StateButton, newProps,
		Immutable.JoinDictionaries(props[Roact.Children] or {}, {LoadingShimmer = loadingShimmer})
	)
end

return LoadableButton