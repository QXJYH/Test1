-- PagingLabelsScrollView

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Colors = require(CorePackages.AppTempCommon.LuaApp.Style.Colors)

local Roact = require(Modules.Common.Roact)

-- Paging Scroll parameters
local PAGING_SCROLL_NAV_BAR_HEIGHT_REMOVE = 40
local PAGING_SCROLL_CONTENT_FONT_SIZE = 40
local PAGING_SCROLL_CONTENT_FONT_COLOR = Colors.White

--- Paging Navigation
local PAGING_NAVIGATION_ACTIVE_COLOR = Colors.White
local PAGING_NAVIGATION_INACTIVE_COLOR = Colors.Graphite
local PAGING_NAVIGATION_BUTTON_SIZE =  UDim2.new(0, 10, 0, 10)
local PAGING_NAVIGATION_DEFAULT_INDEX = 1

local PagingLabelsScrollView = Roact.PureComponent:extend("PagingLabelsScrollView")

function PagingLabelsScrollView:init()

	self.state = {
		currentIndex = PAGING_NAVIGATION_DEFAULT_INDEX
	}

	self.isMounted = false

	self.pageScrollNavigationRef = Roact.createRef()

	self.onActivated = function(index)
		return function()
			spawn(function()
				if self.isMounted then
					self:setState({
						currentIndex = index,
					})
				end
			end)

			self.pageScrollNavigationRef.current:JumpToIndex(index - 1)
		end
	end

	self.onScrollStopped = function()
		if not self.pageScrollNavigationRef.current then
			return
		end

		local currentPageIndex = tonumber(self.pageScrollNavigationRef.current.CurrentPage.Name)
		if (self.state.currentIndex ~= currentPageIndex) then
			spawn(function()
				if self.isMounted then
					self:setState({
						currentIndex = currentPageIndex,
					})
				end
			end)
		end
	end
end

--- Page Navigation Buttons
function PageNavigationControl(props)

	local pageNavigationButtons = {}
	pageNavigationButtons[1] =  Roact.createElement("UIListLayout", {
								Padding = UDim.new(0, 50),
								SortOrder = Enum.SortOrder.LayoutOrder,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								FillDirection = Enum.FillDirection.Horizontal
							})
	for i = 1, #props.labelsTextArray do
		pageNavigationButtons[i+1] = Roact.createElement("ImageButton", {
									Size = PAGING_NAVIGATION_BUTTON_SIZE, 
									BackgroundTransparency = 0,
									BackgroundColor3 = (i == props.currentIndex) and PAGING_NAVIGATION_ACTIVE_COLOR or PAGING_NAVIGATION_INACTIVE_COLOR,
									LayoutOrder = i,
									[Roact.Event.Activated] = props.onActivated(i),
								})
	end
	
	return Roact.createElement("Frame", {
		Size =  props.Size,
		Position = props.Position, 
		BackgroundTransparency = 1,
	}, pageNavigationButtons)
end

function PagingLabelsScrollView:didMount()
	self.isMounted = true
end

function PagingLabelsScrollView:willUnmount()
	self.isMounted = false
end

function PagingLabelsScrollView:render()
	local pagingScrollContentHeight = self.props.contentHeight - PAGING_SCROLL_NAV_BAR_HEIGHT_REMOVE
	local labelsTextArray = self.props.labelsTextArray
	local pagesContent = {} 
	pagesContent["UIPageLayout"]  = Roact.createElement("UIPageLayout",{
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							FillDirection = Enum.FillDirection.Horizontal,
							[Roact.Ref] = self.pageScrollNavigationRef,
							[Roact.Event.Stopped] = self.onScrollStopped,
						})
	
	for i, labelText in ipairs(labelsTextArray) do
		-- giving every page Name corresponging to the index of the page, so
		-- we can detect current page after scrolling is finished (mvlasyuk)
		pagesContent[i] = Roact.createElement("TextLabel", {
								Text = labelText,
								TextSize = PAGING_SCROLL_CONTENT_FONT_SIZE,
								TextColor3 = PAGING_SCROLL_CONTENT_FONT_COLOR,
								Size = UDim2.new(1, 0, 1, 0), 
								BackgroundTransparency = 1,
								Font = Enum.Font.SourceSans,
								TextXAlignment = Enum.TextXAlignment.Center,
								TextYAlignment = Enum.TextYAlignment.Center,
								TextWrapped = true,
							})
	end

	return Roact.createElement("Frame", {
		Size =  self.props.Size,
		Position = self.props.Position,
		LayoutOrder = self.props.LayoutOrder,
		BackgroundTransparency = 1,
	}, {
		PagingScrollContent = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, pagingScrollContentHeight),
			BackgroundTransparency = 1,
		}, pagesContent),
		PagingScrollNavigationBar = Roact.createElement(PageNavigationControl, {
			Size = UDim2.new(1, 0, 0, PAGING_SCROLL_NAV_BAR_HEIGHT_REMOVE),
			Position = UDim2.new(0, 0, 0, pagingScrollContentHeight),
			onActivated = self.onActivated,
			labelsTextArray = labelsTextArray,
			currentIndex = self.state.currentIndex,
		})
	})

end

return PagingLabelsScrollView