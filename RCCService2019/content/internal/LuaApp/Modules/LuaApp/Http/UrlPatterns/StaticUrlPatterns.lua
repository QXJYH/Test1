
return function(UrlBuilder)
	return {
		catalog = UrlBuilder.fromString("www:catalog"),
		buildersClub = UrlBuilder.fromString("www:mobile-app-upgrades/native-ios/bc"),
		profile = UrlBuilder.fromString("www:users/profile"),
		friends = UrlBuilder.fromString("www:users/friends"),
		groups = UrlBuilder.fromString("www:my/groups.aspx"),
		inventory = UrlBuilder.fromString("www:users/inventory"),
		messages = UrlBuilder.fromString("www:my/messages"),
		feed = UrlBuilder.fromString("www:feeds/inapp"),
		develop = UrlBuilder.fromString("www:develop/landing"),
		blog = UrlBuilder.fromString("blog:"),
		help = UrlBuilder.fromString("www:help"),
		about = {
			us = UrlBuilder.fromString("corp:"),
			careers = UrlBuilder.fromString("corp:careers"),
			parents = UrlBuilder.fromString("corp:parents"),
			terms = UrlBuilder.fromString("www:info/terms"),
			privacy = UrlBuilder.fromString("www:info/privacy"),
		},
		settings = {
			account = UrlBuilder.fromString("www:my/account#!/info"),
			security = UrlBuilder.fromString("www:my/account#!/security"),
			privacy = UrlBuilder.fromString("www:my/account#!/privacy"),
			billing = UrlBuilder.fromString("www:my/account#!/billing"),
			notifications = UrlBuilder.fromString("www:my/account#!/notifications"),
		},
	}
end
