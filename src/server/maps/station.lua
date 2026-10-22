return function()
	local tiles = {}

	for y = -64, 64, 32 do
		tiles[64 .. "," .. y] = "wall"
	end

	return {
		spawns = { { -32, 0 }, { -32, 32 }, { -32, -32 } },
		tiles = tiles,
	}
end
