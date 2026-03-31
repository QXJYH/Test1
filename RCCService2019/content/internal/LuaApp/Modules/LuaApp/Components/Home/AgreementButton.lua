local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)

local AppPage = require(Modules.LuaApp.AppPage)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextButton = require(Modules.LuaApp.Components.FitTextButton)
local AgreementPageText = require(Modules.LuaApp.Components.Home.AgreementPageText)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local AgreementButton = Roact.PureComponent:extend("AgreementButton")

function AgreementButton:init()
	self.onActivated = function()
	self.props.navigateDown({ name = AppPage.AgreementPage, detail = self.props.pageId })
	end
end

function AgreementButton:render()
	ArgCheck.isType(self.props.textHeight, "number", "self.props.textHeight")
	ArgCheck.isType(self.props.TextSize, "number", "self.props.TextSize")
	ArgCheck.isType(self.props.pageId, "string", "self.props.pageId")
	
	local theme = self._context.AppTheme
	local localization = self.props.localization
	local textHeight = self.props.textHeight
	local TextSize = self.props.TextSize

	local title = AgreementPageText[self.props.pageId].Title
	local localizedTitle = self.props.localization:Format(title)

	return Roact.createElement(FitTextButton, {
		Size = UDim2.new(0, 0, 0, textHeight),
		Text = localizedTitle,
		TextSize = TextSize,
		Font = theme.Buttons.AgreementButton.Text.Font,
		BackgroundTransparency = 1,
		TextColor3 = theme.Buttons.AgreementButton.Text.Color,
		LayoutOrder = self.props.LayoutOrder,
		fitAxis = FitChildren.FitAxis.Width,
		[Roact.Event.Activated] = self.onActivated,
	})
end

AgreementButton = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			navigateDown = function(page)
				return dispatch(NavigateDown(page))
			end,
		}
	end
)(AgreementButton)

AgreementButton = RoactServices.connect({
	localization = RoactLocalization,
})(AgreementButton)

return AgreementButton