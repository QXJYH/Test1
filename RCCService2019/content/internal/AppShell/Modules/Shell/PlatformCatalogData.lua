local PlatformService = nil
pcall(function() PlatformService = game:GetService('PlatformService') end)

local PlatformCatalogData = {}

local function getStudioDummyData()
	-- do not change example, they account for formatting in different regions
	return {
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$199.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$199.99",
			Price = "199.99",
			ProductId = "210d1d69-5189-40f4-a59b-ecfb4f849847",
			Name = "22,500 Robux", -- comma
			TitleId = 0,
			IsBundle = false
		},
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$4.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$4.99",
			Price = "4.99",
			ProductId = "70c2075d-5e2f-4ffd-8de5-8a6d2f5e65ad",
			Name = "400 Robux",
			TitleId = 0,
			IsBundle = false
		},
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$99.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$99.99",
			Price = "99.99",
			ProductId = "878c642b-cb27-4d5e-a150-a408ea40c41c",
			Name = "10 000 Robux", -- &nbsp
			TitleId = 0,
			IsBundle = false
		},
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$399.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$399.99",
			Price = "399.99",
			ProductId = "878c642b-cb27-4d5e-a150-a408ea40c41c",
			Name = "50 000 Robux", -- space
			TitleId = 0,
			IsBundle = false
		},
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$129.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$129.99",
			Price = "129.99",
			ProductId = "878c642b-cb27-4d5e-a150-a408ea40c41c",
			Name = "12.500 Robux", -- dot
			TitleId = 0,
			IsBundle = false
		},
		{
			ReducedName = "Default Short Title",
			Description = "Default Description",
			DisplayListPrice = "$229.99",
			IsPartOfAnyBundle = false,
			DisplayPrice = "$229.99",
			Price = "229.99",
			ProductId = "878c642b-cb27-4d5e-a150-a408ea40c41c",
			Name = "在Xbox上獲得32500 Robux", -- extended characters
			TitleId = 0,
			IsBundle = false
		},
	}
end

function PlatformCatalogData:GetCatalogInfoAsync()
	if UserSettings().GameSettings:InStudioMode() or game:GetService('UserInputService'):GetPlatform() == Enum.Platform.Windows then
		return getStudioDummyData(),
				true,
				''
	end

	local numRetries = 5
	local catalogInfo, success, errormsg;
	for i = 1, numRetries do
		success, errormsg = pcall(function()
			catalogInfo = PlatformService:BeginGetCatalogInfo()
		end)
		if success and catalogInfo then
			return catalogInfo, success, errormsg
		end
		wait(10)
	end

	return catalogInfo, success, errormsg
end

function PlatformCatalogData:ParseMoneyValue(productInfo)
	local price = productInfo and tonumber(productInfo.Price) or 0.99
	return price
end

function PlatformCatalogData:ParseRobuxValue(productInfo)
	if not productInfo or not productInfo.Name then
		return 0
	end

	local value = string.gsub(productInfo.Name, "%D+", "")
	return tonumber(value)
end

function PlatformCatalogData:CalculateRobuxRatio(productInfo)
	local robuxValue = self:ParseRobuxValue(productInfo)
	local moneyValue = self:ParseMoneyValue(productInfo)
	if moneyValue == 0 or robuxValue == 0 then
		return 0
	end
	return robuxValue / moneyValue
end

return PlatformCatalogData
