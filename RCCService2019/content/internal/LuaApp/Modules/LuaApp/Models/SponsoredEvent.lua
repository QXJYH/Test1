--[[
	{
		"name": string,
		"title": string,
		"imageUrl": string,
		"pageType": string,
		"pagePath": string
	}
]]

local SponsoredEvent = {}

function SponsoredEvent.new()
	local self = {}
	return self
end

function SponsoredEvent.mock()
	local self = SponsoredEvent.new()
	self.name = "Imagination2018"
	self.title = "Imagination2018"
	self.imageUrl = "https://images.rbxcdn.com/ecf1f303830daecfb69f2388c72cb6b8"
	self.pageType = "Sponsored"
	self.pagePath = "/sponsored/Imagination2018"
	return self
end

function SponsoredEvent.fromJsonData(sponsoredEventJson)
	local self = SponsoredEvent.new()
	self.name = sponsoredEventJson.name
	self.title = sponsoredEventJson.title
	self.imageUrl = sponsoredEventJson.logoImageUrl
	self.pageType = sponsoredEventJson.pageType
	self.pagePath = sponsoredEventJson.pagePath
	return self
end

return SponsoredEvent