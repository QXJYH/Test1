local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local Signal = require(Modules.Common.Signal)

local EndOfScroll = require(Modules.LuaApp.Components.EndOfScroll)
local LoadingBarWithTheme = require(Modules.LuaApp.Components.LoadingBarWithTheme)
local RefreshScrollingFrame = require(Modules.LuaApp.Components.RefreshScrollingFrame)
local RefreshScrollingFrameNew = require(Modules.LuaApp.Components.RefreshScrollingFrameNew)

local FFlagLuaAppRefreshScrollingFrameLoadMoreRefactor =
    settings():GetFFlag("LuaAppRefreshScrollingFrameLoadMoreRefactor")
local UseNewRefreshScrollingFrame = FlagSettings.UseNewRefreshScrollingFrame()

if not FFlagLuaAppRefreshScrollingFrameLoadMoreRefactor then
    return RefreshScrollingFrame
end

-- We would like to start loading more before user reaches the bottom.
-- The default distance from the bottom of that would be 2000.
local DEFAULT_PRELOAD_DISTANCE = 2000

local LOADING_BAR_PADDING = 20
local LOADING_BAR_HEIGHT = 16
local LOADING_BAR_TOTAL_HEIGHT = LOADING_BAR_PADDING * 2 + LOADING_BAR_HEIGHT

local RefreshScrollingFrameWithLoadMore = Roact.PureComponent:extend("RefreshScrollingFrameWithLoadMore")

RefreshScrollingFrameWithLoadMore.defaultProps = {
	preloadDistance = DEFAULT_PRELOAD_DISTANCE,
}

function RefreshScrollingFrameWithLoadMore:init()
    self._isMounted = false

    self.scrollToTopSignal = Signal.new()

    self.scrollToTop = function()
        self.scrollToTopSignal:fire()
    end

    self.state = {
        isLoadingMore = false,
        isScrollable = false,
    }

    self.onCanvasPositionChanged = function(rbx)
        local preloadDistance = self.props.preloadDistance
        local onLoadMore = self.props.onLoadMore
        local isLoadingMore = self.state.isLoadingMore
        local newPosition = rbx.CanvasPosition.Y

        local shouldLoadMore

        if UseNewRefreshScrollingFrame then
            local hasMoreRows = self.props.hasMoreRows
            shouldLoadMore = hasMoreRows and not isLoadingMore
        else
            shouldLoadMore = onLoadMore and not isLoadingMore
        end

        -- Check if we want to load more things
        if shouldLoadMore then
            if rbx.CanvasSize.Y.Scale ~= 0 then
                warn([[RefreshScrollingFrame: Scrollingframe.CanvasSize.Y.Scale is not 0!
                Content loading would not work properly.]])
                return
            end

            local loadMoreThreshold = rbx.CanvasSize.Y.Offset - rbx.AbsoluteWindowSize.Y - preloadDistance

            -- dispatch LoadMore
            if newPosition > loadMoreThreshold then
                self:setState({
                    isLoadingMore = true
                })

                onLoadMore():andThen(
                    function()
                        if self._isMounted then
                            self:setState({
                                isLoadingMore = false
                            })
                        end
                    end,
                    function()
                        -- Allow us to retry.
                        if self._isMounted then
                            self:setState({
                                isLoadingMore = false
                            })
                        end
                    end
                )
            end
        end
    end

    self.onCanvasSizeChanged = function(rbx)
        local canvasHeight = rbx.CanvasSize.Y.Offset
        local windowHeight = rbx.AbsoluteWindowSize.Y

        local isScrollable = self._isMounted and canvasHeight > windowHeight

        if isScrollable ~= self.state.isScrollable then
            spawn(function()
                if self._isMounted then
                    self:setState({
                        isScrollable = isScrollable,
                    })
                end
            end)
        end
    end

    -- TODO: remove with flag UseNewRefreshScrollingFrame
    self.createFooter = function()
        local isLoadingMore = self.state.isLoadingMore

        return isLoadingMore and Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, LOADING_BAR_TOTAL_HEIGHT),
        }, {
            LoadingBar = Roact.createElement(LoadingBarWithTheme),
        })
    end
end

function RefreshScrollingFrameWithLoadMore:didMount()
    self._isMounted = true
end

function RefreshScrollingFrameWithLoadMore:willUnmount()
    self._isMounted = false
end

function RefreshScrollingFrameWithLoadMore:render()
    -- RefreshScrollingFrameNew is a PureComponent, so the createFooter function has to actually change
    -- for it to re-render.
    if UseNewRefreshScrollingFrame then
        local hasMoreRows = self.props.hasMoreRows
        local isLoadingMore = self.state.isLoadingMore
        local isScrollable = self.state.isScrollable

        local createFooter = nil

        if isLoadingMore then
            createFooter = function()
                return Roact.createElement("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, LOADING_BAR_TOTAL_HEIGHT),
                }, {
                    LoadingBar = Roact.createElement(LoadingBarWithTheme),
                })
            end
        elseif (not hasMoreRows and isScrollable) then
            createFooter = function()
                return Roact.createElement(EndOfScroll, {
                    backToTopCallback = self.scrollToTop,
                })
            end
        end

        local newProps = Cryo.Dictionary.join(self.props, {
            onCanvasPositionChangedCallback = self.onCanvasPositionChanged,
            onCanvasSizeChangedCallback = self.onCanvasSizeChanged,
            createFooter = createFooter,
            scrollToTopSignal = self.scrollToTopSignal,
            onLoadMore = Cryo.None,
            hasMoreRows = Cryo.None,
        })

        return Roact.createElement(RefreshScrollingFrameNew, newProps)
    else
        local newProps = Cryo.Dictionary.join(self.props, {
            onCanvasPositionChangedCallback = self.onCanvasPositionChanged,
            createFooter = self.createFooter,
            onLoadMore = Cryo.None,
            [Roact.Children] = Cryo.None,
        })

        return Roact.createElement(RefreshScrollingFrame, newProps, self.props[Roact.Children])
    end
end

return RefreshScrollingFrameWithLoadMore