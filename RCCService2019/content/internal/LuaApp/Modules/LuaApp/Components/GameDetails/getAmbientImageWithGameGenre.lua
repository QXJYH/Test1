local Images = {
	General = {
		-- The image was set to an empty string to resolve MOBLUAPP-1811. It
		-- will likely be changed to something else in the future.
		Image = "",
		Size = Vector2.new(1024, 1024),
		Tint = nil,
	},
}

local function getAmbientImageWithGameGenre(genre)
	assert(genre ~= nil, "Genre cannot be nil!")
	return Images[genre] or Images.General
end

return getAmbientImageWithGameGenre