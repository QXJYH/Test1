local Workspace = game:GetService("Workspace")
local RunService = game:GetService('RunService')
local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)

local withStyle = UIBlox.Style.withStyle
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local LoadingBar = require(CorePackages.AppTempCommon.LuaApp.Components.LoadingBar)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

if not UseNewAppStyle then
	-- Use the old LoadingBar when Retheme flags are off.
	return LoadingBar
end

local WHITE_DOT_IMAGE = "LuaApp/buttons/buttonFill"
local WHITE_DOT_IMAGE_SLICE_CENTER = Rect.new(8, 8, 9, 9)
local BAR_MAX_SIZE = 15
local BAR_MAX_AMPLITUDE = 40
local BAR_DIAMETER = 4
local BAR_PERIOD = 1.25

local LoadingBarWithTheme = Roact.Component:extend("LoadingBarWithTheme")

function LoadingBarWithTheme:init()
	self.barRef = Roact.createRef()
end

function LoadingBarWithTheme:render()
	local zIndex = self.props.ZIndex

	return withStyle(function(style)
		return Roact.createElement(ImageSetLabel, {
			Image = WHITE_DOT_IMAGE,
			ImageColor3 = style.Theme.SystemPrimaryDefault.Color,
			ImageTransparency = style.Theme.SystemPrimaryDefault.Transparency,
			ScaleType = "Slice",
			SliceCenter = WHITE_DOT_IMAGE_SLICE_CENTER,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = zIndex,
			[Roact.Ref] = self.barRef,
		})
	end)
end

function LoadingBarWithTheme:didMount()
	self.connection = RunService.RenderStepped:Connect(function()
		local t = Workspace.DistributedGameTime
		local instance = self.barRef.current
		local period = 2.0 * math.pi / BAR_PERIOD

		local width = (BAR_MAX_SIZE/2) * (1 - math.cos(2*t*period))
		instance.Size = UDim2.new(0, BAR_DIAMETER + width, 0, BAR_DIAMETER)

		local x = BAR_MAX_AMPLITUDE * math.cos(t*period)
		instance.Position = UDim2.new(0.5, x - width/2 - BAR_DIAMETER/2, 0.5, 0)
	end)
end

function LoadingBarWithTheme:willUnmount()
	self.connection:Disconnect()
end

return LoadingBarWithTheme