-- LUASTARTUP-54TODO: Unit tests
return function(Str)
	return string.find(Str, "^%+*[%d%-%s%.%(%)]+$")
end
