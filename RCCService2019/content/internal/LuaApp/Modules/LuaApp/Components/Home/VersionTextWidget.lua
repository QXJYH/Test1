local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactServices = require(Modules.LuaApp.RoactServices)

local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local FitChildren = require(Modules.LuaApp.FitChildren)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local VersionTextWidget = Roact.PureComponent:extend("VersionTextWidget")

local TEXT_LABEL_TRANSPARENCY = 0.5
local PADDING_LEFT = 10

function VersionTextWidget:render()
	ArgCheck.isType(self.props.textHeight, "number", "self.props.textHeight")
	ArgCheck.isType(self.props.TextSize, "number", "self.props.TextSize")
	
	local theme = self._context.AppTheme
	local runService = self.props.runService
	local textHeight = self.props.textHeight
	local TextSize = self.props.TextSize

	assert(runService, "RunService must be set.")
	local robloxVersion = runService:GetRobloxVersion()

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BackgroundTransparency = 1,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 0),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, PADDING_LEFT),
		}),
		VersionTextLabel = Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(1, 0, 0, textHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = { "CommonUI.Features.Label.VersionWithNumber", versionNumber = robloxVersion },
			Font = theme.Buttons.AgreementButton.Text.Font,
			TextSize = TextSize,
			TextColor3 = theme.Buttons.AgreementButton.Text.Color,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTransparency = TEXT_LABEL_TRANSPARENCY,
		})
	})
end

VersionTextWidget = RoactServices.connect({
	runService = AppRunService,
})(VersionTextWidget)

return VersionTextWidget