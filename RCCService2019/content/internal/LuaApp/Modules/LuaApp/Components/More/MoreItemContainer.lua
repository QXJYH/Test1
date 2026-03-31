local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AppPage = require(Modules.LuaApp.AppPage)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)

local MoreButton = require(Modules.LuaApp.Components.More.MoreButton)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local Logout = require(Modules.LuaApp.Thunks.Authentication.Logout)


local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")

local MoreItemContainer = Roact.PureComponent:extend("MoreItemContainer")

MoreItemContainer.defaultProps = {
	layoutInfo = {}
}

function MoreItemContainer:init()
	self.openWebPage = function()
		local item = self.props.item
		local url = item.context.url
		if item.urlGenerator then
			local localUserId = self.props.localUserId
			url = item.urlGenerator(localUserId)
		end

		self.props.navigateDown({
			name = AppPage.GenericWebPage,
			detail = url,
			extraProps = {
				titleKey = item.context.titleKey,
			},
		})
	end

	self.navigateDown = function()
		local context = self.props.item.context
		self.props.navigateDown({
			name = context.page,
		})
	end

	self.broadcastNotification = function()
		local context = self.props.item.context
		self.props.guiService:BroadcastNotification(context.notificationData, context.notificationType)
	end

	self.onActivated = function()
		local item = self.props.item
		if item.itemType == MorePageSettings.ItemType.Events or
			item.itemType == MorePageSettings.ItemType.Settings or
			item.itemType == MorePageSettings.ItemType.About then
			self.navigateDown()
		elseif item.itemType == MorePageSettings.ItemType.LogOut then
			if FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
				self.props.logout(self.props.networkImpl)
			else
				if FFlagEnablePopupDataModelFocusedEvents then
					self.navigateDown()
				else
					self.broadcastNotification()
				end
			end
        elseif item.itemType == MorePageSettings.ItemType.BuildersClub then
            self.broadcastNotification()
		else
			self.openWebPage()
		end
	end
end

function MoreItemContainer:render()
	local layoutInfo = self.props.layoutInfo
	local item = self.props.item

	ArgCheck.isType(layoutInfo, "table", "MoreItemContainer.props.layoutInfo")
	ArgCheck.isType(item, "table", "MoreItemContainer.props.item")

	return Roact.createElement(MoreButton, Cryo.Dictionary.join(layoutInfo, {
		Text = item.textKey,
		TextXAlignment = item.textXAlignment,
		icon = item.icon,
		rightImage = item.rightImage,
		badgeComponent = item.badgeComponent,
		badgeCount = item.badgeCount,
		onActivated = self.onActivated,
	}))
end

MoreItemContainer = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			localUserId = state.LocalUserId,
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
			logout = function(networkImpl)
				dispatch(Logout(networkImpl))
			end
		}
	end
)(MoreItemContainer)

return RoactServices.connect({
	guiService = AppGuiService,
	networkImpl = RoactNetworking
})(MoreItemContainer)
