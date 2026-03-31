local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.LuaApp.withLocalization)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)
local ItemListLayout = require(Modules.LuaApp.Components.Generic.ItemListLayout)
local BirthdayPicker = require(Modules.LuaApp.Components.Generic.BirthdayPicker)

local SignupLayout = require(Modules.LuaApp.Components.Login.SignUpLayout)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local BIRTHDAY_PICKER_WIDGET_PADDING = 20
local BACKGROUND_IMAGE = "LuaApp/buttons/buttonFill"

local BirthdayPage = Roact.PureComponent:extend("BirthdayPage")

function BirthdayPage:init()
	self.renderWidget = function(props)
		local formFactor = props.formFactor

		if UseNewAppStyle then
			return withStyle(function(style)
				return withLocalization({
					continueText = "Feature.GameDetails.Action.Continue",
				})(function(localizedStrings)
					local backgroundTransparency = 1

					if formFactor == FormFactor.COMPACT then
						backgroundTransparency = style.Theme.BackgroundDefault.Transparency
					end

					return Roact.createElement(FitChildren.FitImageLabel, {
						Size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
						BackgroundColor3 = style.Theme.BackgroundDefault.Color,
						BackgroundTransparency = backgroundTransparency,
						BorderSizePixel = 0,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(9, 9, 9, 9),
						ClipsDescendants = true,
						Image = BACKGROUND_IMAGE,
						ImageColor3 = style.Theme.BackgroundDefault.Color,
						ImageTransparency = style.Theme.BackgroundDefault.Transparency,
					}, {
						ListLayout = Roact.createElement("UIListLayout"),
						Padding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, BIRTHDAY_PICKER_WIDGET_PADDING),
							PaddingRight = UDim.new(0, BIRTHDAY_PICKER_WIDGET_PADDING),
							PaddingTop = UDim.new(0, BIRTHDAY_PICKER_WIDGET_PADDING),
							PaddingBottom = UDim.new(0, BIRTHDAY_PICKER_WIDGET_PADDING),
						}),
						ContentList = Roact.createElement(ItemListLayout, {
							size = UDim2.new(1, 0, 0, 0),
							fitAxis = FitChildren.FitAxis.Height,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 10),
							renderItemList = {
								Roact.createElement(BirthdayPicker),
							},
						}),
					})
				end)
			end)
		else
			return nil
		end
	end
end

function BirthdayPage:render()
	return Roact.createElement(SignupLayout, {
		titleTextKey = "Authentication.SignUp.Label.WhensYourBirthday",
		-- TODO Pass down paragraphTextKey when the phrase is finalized
		-- paragraphTextKey = "Authentication.SignUp.Message.WhenIsYourBirthday",
		renderWidget = self.renderWidget,
	})
end

return BirthdayPage