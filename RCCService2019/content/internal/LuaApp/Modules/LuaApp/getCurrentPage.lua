return function(state)
	local routeHistory = state.Navigation.history
	local route = routeHistory[#routeHistory]
	local page = route[#route]

	return page.name
end