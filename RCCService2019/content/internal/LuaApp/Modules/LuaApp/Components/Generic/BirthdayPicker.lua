local CorePackages = game:GetService("CorePackages")
local LocalizationService = game:GetService("LocalizationService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local FitChildren = require(Modules.LuaApp.FitChildren)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local TimeUnit = require(CorePackages.AppTempCommon.LuaChat.TimeUnit)
local DateTime = require(CorePackages.AppTempCommon.LuaChat.DateTime)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.LuaApp.withLocalization)

local GenericTextButton = require(Modules.LuaApp.Components.GenericTextButton)
local ScrollingPicker = require(Modules.LuaApp.Components.Login.ScrollingPicker)

local PICKER_OUTER_PADDING = 5
local PICKER_ENTRY_HEIGHT = 50
local PICKER_HEIGHT = 200

local DEFAULT_MONTH = 1
local DEFAULT_DAY = 1
local DEFAULT_YEAR_OFFSET = -1

local CONTINUE_BUTTON_HEIGHT = 44

local ReasonDateInvalid = {
	IsFutureDate = "IsFutureDate",
	IsInvalidDayOfMonth = "IsInvalidDayOfMonth",
}

local MONTHS_KEYS = {
	"CommonUI.Controls.Label.January",
	"CommonUI.Controls.Label.February",
	"CommonUI.Controls.Label.March",
	"CommonUI.Controls.Label.April",
	"CommonUI.Controls.Label.May",
	"CommonUI.Controls.Label.June",
	"CommonUI.Controls.Label.July",
	"CommonUI.Controls.Label.August",
	"CommonUI.Controls.Label.September",
	"CommonUI.Controls.Label.October",
	"CommonUI.Controls.Label.November",
	"CommonUI.Controls.Label.December",
}

local DAYS = {}
for i = 1, 31 do
	table.insert(DAYS, i)
end

-- TODO Add this to DateLocalization.lua under LuaApp/Util
local DateTypeOrder = setmetatable(
	{
		["en-us"] = {
			[TimeUnit.Months] = 0,
			[TimeUnit.Days] = 1,
			[TimeUnit.Years] = 2,
		}
	}, {
		__index = function(DateTypeOrder, key)
			return DateTypeOrder["en-us"]
		end,
	}
)

--[[

	Helper functions for date math

	TODO Need to refactor these out of BirthdayPicker https://jira.rbx.com/browse/LUASTARTUP-30

--]]
local function mod(a, b)
    return a - math.floor(a / b) * b
end

local function isLeapYear(year)
	return mod(year, 4) == 0 and (mod(year, 100) ~= 0 or mod(year, 400) == 0)
end

local lastDaysOfTheMonthInYear = {}

local function getLastDayOfTheMonthInYear(month, year)
	if lastDaysOfTheMonthInYear[month] and lastDaysOfTheMonthInYear[month][year] then
		return lastDaysOfTheMonthInYear[month][year]
	else
		local lastDay
		if month == 2 then
			lastDay = isLeapYear(year) and 29 or 28
		elseif mod(month, 2) == 0 and month < 7
			or mod(month, 2) == 1 and month > 7 then
			lastDay = 30
		else
			lastDay = 31
		end

		if not lastDaysOfTheMonthInYear[month] then
			lastDaysOfTheMonthInYear[month] = {}
		end
		lastDaysOfTheMonthInYear[month][year] = lastDay

		return lastDay
	end
end

local BirthdayPicker = Roact.PureComponent:extend("BirthdayPicker")

BirthdayPicker.defaultProps = {
	minAgeAllowed = 0,
	maxAgeAllowed = 100,
}

function BirthdayPicker:init()
	self.isMounted = false

	self.state = {
		selectedMonthIndex = 1,
		selectedDayIndex = 1,
		selectedYearIndex = 1,
		continueButtonEnabled = true,
	}

	-- TODO Get the current date from the store, and re-populate dummyYears when the year changes.
	-- LUASTARTUP-19 needs to be addressed first before enabling dynamic dates.
	local currentTime = DateTime.now():GetValues()

	self.currentDate = {
		[TimeUnit.Months] = ArgCheck.isNonNegativeNumber(currentTime.Month, "current month in BirthdayPicker"),
		[TimeUnit.Days] = ArgCheck.isNonNegativeNumber(currentTime.Day, "current day in BirthdayPicker"),
		[TimeUnit.Years] = ArgCheck.isNonNegativeNumber(currentTime.Year, "current year in BirthdayPicker"),
	}

	local currentYear = self.currentDate[TimeUnit.Years]
	local minAgeAllowed = self.props.minAgeAllowed
	local maxAgeAllowed = self.props.maxAgeAllowed

	local minYear = currentYear - maxAgeAllowed
	local maxYear = currentYear - minAgeAllowed

	self.dummyYears = {}
	for year = minYear, maxYear do
		table.insert(self.dummyYears, year)
	end

	self.renderMonth = function(monthKey)
		return withStyle(function(style)
			return withLocalization({
				monthText = monthKey,
			})(function(localizedStrings)
				return Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = localizedStrings.monthText,
					Font = style.Font.Header2.Font,
					TextSize = style.Font.BaseSize * style.Font.Header2.RelativeSize,
					TextColor3 = style.Theme.TextEmphasis.Color,
					TextTransparency = style.Theme.TextEmphasis.Transparency,
				})
			end)
		end)
	end

	self.renderYear = function(year)
		return withStyle(function(style)
			return Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = tostring(year),
				Font = style.Font.Header2.Font,
				TextSize = style.Font.BaseSize * style.Font.Header2.RelativeSize,
				TextColor3 = style.Theme.TextEmphasis.Color,
				TextTransparency = style.Theme.TextEmphasis.Transparency,
			})
		end)
	end

	self.onSelectedIndexChangedForMonth = function(index)
		local selectedMonthIndex = self.state.selectedMonthIndex

		if selectedMonthIndex ~= index then
			spawn(function()
				if self.isMounted then
					self:setState({
						selectedMonthIndex = index,
					})
				end
			end)
		end
	end

	self.onSelectedIndexChangedForDay = function(index)
		local selectedDayIndex = self.state.selectedDayIndex

		if selectedDayIndex ~= index then
			spawn(function()
				if self.isMounted then
					self:setState({
						selectedDayIndex = index,
					})
				end
			end)
		end
	end

	self.onSelectedIndexChangedForYear = function(index)
		local selectedYearIndex = self.state.selectedYearIndex

		if selectedYearIndex ~= index then
			spawn(function()
				if self.isMounted then
					self:setState({
						selectedYearIndex = index,
					})
				end
			end)
		end
	end
end

function BirthdayPicker:didMount()
	self.isMounted = true
end

function BirthdayPicker:willUnmount()
	self.isMounted = false
end

--[[

	Helper functions for dates

--]]
function BirthdayPicker:isFutureDate(month, day, year)
	local currentDate = self.currentDate

	if year > currentDate[TimeUnit.Years] then
		return true
	elseif year == currentDate[TimeUnit.Years]
		and month > currentDate[TimeUnit.Months] then
		return true
	elseif year == currentDate[TimeUnit.Years]
		and month == currentDate[TimeUnit.Months]
		and day > currentDate[TimeUnit.Days] then
		return true
	end

	return false
end

function BirthdayPicker:isInvalidDayOfTheMonth(month, day, year)
	return day > getLastDayOfTheMonthInYear(month, year)
end

-- BirthdayPicker:isInvalidDate
-- Input Parameters:
--     month in number
--     day in number
--     year in number
-- Return Values: (in the order mentioned)
--     isValid in boolean
--     reasonInvalid in ReasonDateInvalid
function BirthdayPicker:isValidDate(month, day, year)
	if self:isInvalidDayOfTheMonth(month, day, year) then
		return false, ReasonDateInvalid.IsInvalidDayOfMonth
	elseif self:isFutureDate(month, day, year) then
		return false, ReasonDateInvalid.IsFutureDate
	end

	return true, nil
end

function BirthdayPicker:updatePickerState()
	local selectedMonthIndex = self.state.selectedMonthIndex
	local selectedDayIndex = self.state.selectedDayIndex
	local selectedYearIndex = self.state.selectedYearIndex
	local year = self.dummyYears[selectedYearIndex]

	local needToUpdateDay = false
	local needToUpdateMonth = false

	local isValidDate, reasonDateInvalid = self:isValidDate(selectedMonthIndex, selectedDayIndex, year)
	if not isValidDate then
		if reasonDateInvalid == ReasonDateInvalid.IsFutureDate then
			needToUpdateMonth = true
			needToUpdateDay = true
			selectedMonthIndex = self.currentDate[TimeUnit.Months]
			selectedDayIndex = self.currentDate[TimeUnit.Days]
		elseif reasonDateInvalid == ReasonDateInvalid.IsInvalidDayOfMonth then
			needToUpdateDay = true
			selectedDayIndex = getLastDayOfTheMonthInYear(selectedMonthIndex, year)
		end
	end

	spawn(function()
		if self.isMounted then
			self:setState({
				selectedMonthIndex = needToUpdateMonth and selectedMonthIndex or nil,
				selectedDayIndex = needToUpdateDay and selectedDayIndex or nil,
				continueButtonEnabled = isValidDate,
			})
		end
	end)
end

function BirthdayPicker:didUpdate()
	local monthIndex = self.state.selectedMonthIndex
	local dayIndex = self.state.selectedDayIndex
	local yearIndex = self.state.selectedYearIndex
	local year = self.dummyYears[yearIndex]
	local continueButtonEnabled = self.state.continueButtonEnabled

	if self:isValidDate(monthIndex, dayIndex, year) ~= continueButtonEnabled then
		self:updatePickerState()
	end
end

function BirthdayPicker:render()
	local dateTypeOrderForCurrentLocale = DateTypeOrder[LocalizationService.RobloxLocaleId]

	local currentDate = self.currentDate
	local selectedMonthIndex = self.state.selectedMonthIndex
	local selectedDayIndex = self.state.selectedDayIndex
	local selectedYearIndex = self.state.selectedYearIndex
	local continueButtonEnabled = self.state.continueButtonEnabled

	return withStyle(function(style)
		return withLocalization({
			continueText = "Feature.GameDetails.Action.Continue",
			currentMonthText = MONTHS_KEYS[currentDate[TimeUnit.Months]],
			selectedMonthText = MONTHS_KEYS[selectedMonthIndex],
		})(function(localizedStrings)
			local selectedDateString = "Selected Date: "
										..tostring(localizedStrings.selectedMonthText).."-"
										..tostring(DAYS[selectedDayIndex]).."-"
										..tostring(self.dummyYears[selectedYearIndex])

			return Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				fitAxis = FitChildren.FitAxis.Height,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				ListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				TextsForTest = Roact.createElement(FitChildren.FitFrame, {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 0),
					fitAxis = FitChildren.FitAxis.Height,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
				}, {
					ListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
					}),
					SelectedDate = Roact.createElement("TextLabel", {
						LayoutOrder = 2,
						Size = UDim2.new(1, 0, 0, 50),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Text = selectedDateString,
						Font = style.Font.Header2.Font,
						TextSize = style.Font.BaseSize * style.Font.Header2.RelativeSize,
						TextColor3 = style.Theme.TextEmphasis.Color,
						TextTransparency = style.Theme.TextEmphasis.Transparency,
					}),
				}),
				WheelContainer = Roact.createElement(FitChildren.FitFrame, {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0),
					fitAxis = FitChildren.FitAxis.Height,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					ClipsDescendants = true,
				}, {
					ListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, PICKER_OUTER_PADDING),
						PaddingRight = UDim.new(0, PICKER_OUTER_PADDING),
						PaddingTop = UDim.new(0, PICKER_OUTER_PADDING),
						PaddingBottom = UDim.new(0, PICKER_OUTER_PADDING),
					}),
					MonthWheel = Roact.createElement(ScrollingPicker, {
						layoutOrder = dateTypeOrderForCurrentLocale[TimeUnit.Months],
						size = UDim2.new(0.33, 0, 0, PICKER_HEIGHT),
						renderEntry = self.renderMonth,
						entries = MONTHS_KEYS,
						entrySizeOnScrollingAxis = PICKER_ENTRY_HEIGHT,
						initialIndex = DEFAULT_MONTH,
						onSelectedIndexChanged = self.onSelectedIndexChangedForMonth,
						parentSpecifiedTarget = selectedMonthIndex,
					}),
					DayWheel = Roact.createElement(ScrollingPicker, {
						layoutOrder = dateTypeOrderForCurrentLocale[TimeUnit.Days],
						size = UDim2.new(0.33, 0, 0, PICKER_HEIGHT),
						renderEntry = function(day)
							local selectedMonth = self.state.selectedMonthIndex
							local selectedYear = self.dummyYears[self.state.selectedYearIndex]

							return withStyle(function(style)
								local textColor = style.Theme.TextEmphasis.Color
								local textTransparency = style.Theme.TextEmphasis.Transparency

								if self:isInvalidDayOfTheMonth(selectedMonth, day, selectedYear) then
									textColor = style.Theme.TextMuted.Color
									textTransparency = style.Theme.TextMuted.Transparency
								end

								return Roact.createElement("TextLabel", {
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Text = tostring(day),
									Font = style.Font.Header2.Font,
									TextSize = style.Font.BaseSize * style.Font.Header2.RelativeSize,
									TextColor3 = textColor,
									TextTransparency = textTransparency,
								})
							end)
						end,
						entries = DAYS,
						entrySizeOnScrollingAxis = PICKER_ENTRY_HEIGHT,
						initialIndex = DEFAULT_DAY,
						onSelectedIndexChanged = self.onSelectedIndexChangedForDay,
						parentSpecifiedTarget = selectedDayIndex,
					}),
					YearWheel = Roact.createElement(ScrollingPicker, {
						layoutOrder = dateTypeOrderForCurrentLocale[TimeUnit.Years],
						size = UDim2.new(0.33, 0, 0, PICKER_HEIGHT),
						renderEntry = self.renderYear,
						entries = self.dummyYears,
						entrySizeOnScrollingAxis = PICKER_ENTRY_HEIGHT,
						initialIndex = #self.dummyYears + DEFAULT_YEAR_OFFSET,
						onSelectedIndexChanged = self.onSelectedIndexChangedForYear,
						parentSpecifiedTarget = selectedYearIndex,
					}),
				}),
				ContinueButton = Roact.createElement(GenericTextButton, {
					LayoutOrder = 3,
					Size = UDim2.new(1, 0, 0, CONTINUE_BUTTON_HEIGHT),
					Text = localizedStrings.continueText,
					Font = style.Font.Header2.Font,
					TextSize = style.Font.BaseSize * style.Font.Header2.RelativeSize,
					themeSettings = {
						Color = style.Theme.SystemPrimaryDefault.Color,
						Transparency = style.Theme.SystemPrimaryDefault.Transparency,
						DisabledColor = style.Theme.SystemPrimaryContent.Color,
						DisabledTransparency = style.Theme.SystemPrimaryContent.Transparency,
						OnPressColor = style.Theme.SystemPrimaryDefault.Color,
						OnPressTransparency = style.Theme.SystemPrimaryDefault.Transparency,
						Text = {
							Color = style.Theme.SystemPrimaryContent.Color,
							Transparency = style.Theme.SystemPrimaryContent.Transparency,
						},
						Border = {
							Hidden = false,
							Transparency = 1,
						},
					},
					isDisabled = not continueButtonEnabled,
					isLoading = false,
				}),
			})
		end)
	end)
end

return BirthdayPicker