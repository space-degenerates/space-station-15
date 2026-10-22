return function()
	local tiles = {}

	for x = -128, 128, 32 do
		tiles[x .. "," .. -96] = "wall"
		tiles[x .. "," .. 96] = "wall"
	end

	for y = -96, 96, 32 do
		tiles[-128 .. "," .. y] = "wall"
		tiles[128 .. "," .. y] = "wall"
	end

	tiles[-32 .. "," .. 0] = "wall"
	tiles[0 .. "," .. -32] = "wall"
	tiles[32 .. "," .. 32] = "wall"

	return {
		spawns = { { -64, 0 }, { 0, 64 }, { 64, 0 } },
		tiles = tiles,
	}
end
