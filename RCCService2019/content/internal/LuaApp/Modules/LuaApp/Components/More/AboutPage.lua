--[[
About page
_____________________
|                   |
|       TopBar      |
|___________________|
|   AboutPageList   |
|     _________     |
|     | Row 1 |     |
|     | Row 2 |     |
|     | Row 3 |     |
|     | Row 4 |     |
|     | Row 5 |     |
|     |_______|     |
|                   |
|   BuildVersion    |
|___________________|
]]

local CorePackages = game:GetService("CorePackages")
local RunService = game:GetService("RunService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
local withLocalization = require(Modules.LuaApp.withLocalization)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local MoreList = require(Modules.LuaApp.Components.More.MoreList)
local MoreItemContainer = require(Modules.LuaApp.Components.More.MoreItemContainer)
local MorePageScrollingFrame = require(Modules.LuaApp.Components.More.MorePageScrollingFrame)

local robloxVersion = RunService:GetRobloxVersion()

local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local EnableFmodCredits = settings():GetFFlag("LuaAppEnableFmodCredits")
local FixMorePageScroll = FlagSettings.FixMorePageScroll()

local AboutPage = Roact.PureComponent:extend("AboutPage")

function AboutPage:init()
	self.aboutPageItemList = MorePageSettings.GetItemsInPage(AppPage.About)

	self.renderItem = function(item, itemLayoutInfo)
		return Roact.createElement(MoreItemContainer, {
			item = item,
			layoutInfo = itemLayoutInfo,
		})
	end
end

function AboutPage:render()
	local theme = self._context.AppTheme

	local formFactor = self.props.formFactor
	local topBarHeight = self.props.topBarHeight
	local isWideView = formFactor == FormFactor.WIDE

	local renderAboutPage = function(localized, backgroundStyle, textStyle)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = backgroundStyle.Color,
			BackgroundTransparency = backgroundStyle.Transparency,
		}, {
			TopBar = Roact.createElement(TopBar, {
				showBuyRobux = true,
				showNotifications = true,
			}),
			-- Clean up props when remove FFlagFixMorePageScroll
			Scroller = Roact.createElement(FixMorePageScroll and MorePageScrollingFrame or FitChildren.FitScrollingFrame, {
				Position = UDim2.new(0, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, -topBarHeight),
				CanvasSize = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,
				ClipsDescendants = false,
				fitFields = {
					CanvasSize = FitChildren.FitAxis.Height,
				},
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, Constants.MORE_PAGE_SECTION_PADDING),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_HORINZONTAL or 0),
					PaddingRight = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_HORINZONTAL or 0),
					PaddingTop = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_VERTICAL or
						Constants.MORE_PAGE_SECTION_PADDING),
					PaddingBottom = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_VERTICAL or
						Constants.MORE_PAGE_SECTION_PADDING),
				}),
				AboutPageList = Roact.createElement(MoreList, {
					LayoutOrder = 1,
					itemList = self.aboutPageItemList,
					renderItem = self.renderItem,
					rowHeight = Constants.MORE_PAGE_ROW_HEIGHT,
				}),
				FmodCreditsText = EnableFmodCredits and Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, textStyle.Size),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = localized.fmodCreditsText,
					Font = textStyle.Font,
					TextSize = textStyle.Size,
					TextColor3 = textStyle.Color,
					TextTransparency = textStyle.Transparency,
					LayoutOrder = 2,
				}),
				BuildVersionText = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, textStyle.Size),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = localized.buildVersionText,
					Font = textStyle.Font,
					TextSize = textStyle.Size,
					TextColor3 = textStyle.Color,
					TextTransparency = textStyle.Transparency,
					LayoutOrder = EnableFmodCredits and 3 or 2,
				}),
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			local textStyle = Cryo.Dictionary.join(style.Theme.TextDefault, {
				Font = style.Font.Footer.Font,
				Size = style.Font.BaseSize * style.Font.Footer.RelativeSize
			})

			return withLocalization({
				buildVersionText = { "CommonUI.Features.Label.VersionWithNumber", versionNumber = robloxVersion },
				fmodCreditsText = "CommonUI.Features.Label.FMODCredits",
			})(function(localized)
				return renderAboutPage(localized, style.Theme.BackgroundDefault, textStyle)
			end)
		end)
	else
		return withLocalization({
			buildVersionText = { "CommonUI.Features.Label.VersionWithNumber", versionNumber = robloxVersion },
			fmodCreditsText = "CommonUI.Features.Label.FMODCredits",
		})(function(localized)
			return renderAboutPage(localized, theme.MorePage.Background, theme.MorePage.Footer)
		end)
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			topBarHeight = state.TopBar.topBarHeight,
		}
	end
)(AboutPage)
