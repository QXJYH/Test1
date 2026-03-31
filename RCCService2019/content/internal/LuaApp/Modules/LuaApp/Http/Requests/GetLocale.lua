local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

-- Response format
--[[
{
	"signupAndLogin": {
	  "id": 1,
	  "locale": "en_us",
	  "name": "English(US)",
	  "nativeName": "English",
	  "language": {
		"id": 41,
		"name": "English",
		"nativeName": "English",
		"languageCode": "en"
	  }
	},
	"generalExperience": {
	  "id": 1,
	  "locale": "en_us",
	  "name": "English(US)",
	  "nativeName": "English",
	  "language": {
		"id": 41,
		"name": "English",
		"nativeName": "English",
		"languageCode": "en"
	  }
	},
	"ugc": {
	  "id": 1,
	  "locale": "en_us",
	  "name": "English(US)",
	  "nativeName": "English",
	  "language": {
		"id": 41,
		"name": "English",
		"nativeName": "English",
		"languageCode": "en"
	  }
	}
  }
]]

return function(requestImpl)
	local url = string.format("%sv1/locales/user-localization-locus-supported-locales", Url.LOCALE)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end