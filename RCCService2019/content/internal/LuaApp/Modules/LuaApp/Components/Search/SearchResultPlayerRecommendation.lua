local ContentProvider = game:GetService("ContentProvider")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local FitTextButton = require(Modules.LuaApp.Components.FitTextButton)
local FitChildren = require(Modules.LuaApp.FitChildren)
local LocalizedFitTextLabel = require(Modules.LuaApp.Components.LocalizedFitTextLabel)

local encodeURIComponent = require(Modules.LuaApp.Http.encodeURIComponent)

local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local LABEL_TEXT = "Feature.GamePage.LabelSearchInsteadForPlayersNamed"
local LABEL_TITLE = "CommonUI.Features.Label.Players"

local TITLE_KEYWORD_PADDING = 2
local SEARCH_RESULT_TEXT_SIZE = 18

local SearchResultPlayerRecommendation = Roact.PureComponent:extend("GamesSearchForPlayers")

function SearchResultPlayerRecommendation:init()
	self.onPlayerSearchButtonActivated = function()
		local analytics = self.props.analytics
		local guiService = self.props.guiService
		local keyword = self.props.keyword
		local localization = self.props.localization
		local openWebview = self.props.openWebview

		local baseUrl = ContentProvider.BaseUrl
		local url
		if FFlagLuaAppHttpsWebViews then
			url = UrlBuilder.user.search({keyword = keyword})
		else
			url = baseUrl .. "/search/users?keyword=" .. encodeURIComponent(keyword)
		end
		local title = localization:Format(LABEL_TITLE)

		analytics.reportTouchSearchInsteadForPlayerNamed(keyword)
		openWebview(url, title, guiService)
	end
end

function SearchResultPlayerRecommendation:render()
	local keyword = self.props.keyword
	local layoutOrder = self.props.layoutOrder

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
				LayoutOrder = layoutOrder,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
				}),
				PlayerSearchTitleText = Roact.createElement(LocalizedFitTextLabel, {
					Text = LABEL_TEXT,
					LayoutOrder = 1,
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 1,
					TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
					Font = style.Font.Body.Font,
					TextColor3 = style.Theme.TextDefault.Color,
					TextTransparency = style.Theme.TextDefault.Transparency,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					fitAxis = FitChildren.FitAxis.Width,
				}),
				PlayerSearchKeyword = Roact.createElement(FitTextButton, {
					Text = keyword,
					LayoutOrder = 2,
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 1,
					TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
					Font = style.Font.Body.Font,
					TextColor3 = style.Theme.TextEmphasis.Color,
					TextTransparency = style.Theme.TextEmphasis.Transparency,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					fitAxis = FitChildren.FitAxis.Width,
					[Roact.Event.Activated] = self.onPlayerSearchButtonActivated,
				}, {
					-- We can achieve the underline with RichText once the feature is stable.
					Underline = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, 1),
						Position = UDim2.new(0, 0, 1, -1),
						BackgroundColor3 = style.Theme.TextEmphasis.Color,
						BackgroundTransparency = style.Theme.TextEmphasis.Transparency,
					}),
				}),
			})
		end)
	else
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
			LayoutOrder = layoutOrder,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
			}),
			PlayerSearchTitleText = Roact.createElement(LocalizedFitTextLabel, {
				Text = LABEL_TEXT,
				LayoutOrder = 1,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundTransparency = 1,
				TextSize = SEARCH_RESULT_TEXT_SIZE,
				TextColor3 = Constants.Color.GRAY1,
				Font = Enum.Font.SourceSansLight,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				fitAxis = FitChildren.FitAxis.Width,
			}),
			PlayerSearchKeyword = Roact.createElement(FitTextButton, {
				Text = keyword,
				LayoutOrder = 2,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundTransparency = 1,
				TextSize = SEARCH_RESULT_TEXT_SIZE,
				TextColor3 = Constants.Color.BLUE_PRIMARY,
				Font = Enum.Font.SourceSansBold,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				fitAxis = FitChildren.FitAxis.Width,
				[Roact.Event.Activated] = self.onPlayerSearchButtonActivated,
			}),
		})
	end
end

return SearchResultPlayerRecommendation
