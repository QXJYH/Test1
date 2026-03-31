local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local AELoader = require(Modules.LuaApp.Components.Avatar.AELoader)
local FetchLocalUserAvatar = require(Modules.LuaApp.Thunks.FetchLocalUserAvatar)

local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")
local FFlagLuaRemoveRoactRoduxConnectUsage = game:GetFastFlag("LuaRemoveRoactRoduxConnectUsage")

local RoactAvatarEditorWrapper = Roact.Component:extend("RoactAvatarEditorWrapper")

function RoactAvatarEditorWrapper:render()
	return Roact.createElement(AELoader, self.props)
end

function RoactAvatarEditorWrapper:didUpdate(prevProps, prevState)
	local networking = self.props.networking
	local fetchUserThumbnail = self.props.fetchUserThumbnail

	local prevIsVisible = prevProps.isVisible
	local isVisible = self.props.isVisible

	local useHomePageWithAvatarAndPanel = self.props.useHomePageWithAvatarAndPanel

	if useHomePageWithAvatarAndPanel then
		if prevIsVisible and not isVisible then
			fetchUserThumbnail(networking)
		end
	end
end

if FFlagLuaRemoveRoactRoduxConnectUsage then
	RoactAvatarEditorWrapper = RoactRodux.UNSTABLE_connect2(
		nil,
		function(dispatch)
			return {
				fetchUserThumbnail = function(networking)
					return dispatch(FetchLocalUserAvatar.Fetch(networking))
				end,
			}
		end
	)(RoactAvatarEditorWrapper)
else
	RoactAvatarEditorWrapper = RoactRodux.connect(function(store, props)
		return {
			store = store,
			fetchUserThumbnail = function(networking)
				return store:dispatch(FetchLocalUserAvatar.Fetch(networking))
			end,
		}
	end
	)(RoactAvatarEditorWrapper)
end

RoactAvatarEditorWrapper = RoactServices.connect({
	networking = RoactNetworking,
})(RoactAvatarEditorWrapper)

if FFlagLuaAppPolicyRoactConnector then
	RoactAvatarEditorWrapper = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			useHomePageWithAvatarAndPanel = appPolicy.getUseHomePageWithAvatarAndPanel(),
		}
	end)(RoactAvatarEditorWrapper)
else
	RoactAvatarEditorWrapper = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			useHomePageWithAvatarAndPanel = appPolicy and appPolicy.getUseHomePageWithAvatarAndPanel(),
		}
	end)(RoactAvatarEditorWrapper)
end

return RoactAvatarEditorWrapper
