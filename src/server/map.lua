local maps = require("server.maps")

local map = {}

map.tiles = {}
map.spawns = {}

function map.load(id)
	local data = maps.load(id)
    if not data then return false end
    print(#map.tiles, #map.spawns)
    map.tiles = {}
	map.spawns = {}
    for key, name in next, data.tiles do
        Server.entityCount = Server.entityCount + 1
        map.tiles[key] = {id = name, eid = Server.entityCount}
    end
    map.spawns = data.spawns
	print("mapload")
	return true
end

function map.serialize()
	local parts = {}
    for key, id in pairs(map.tiles) do
		parts[#parts + 1] = key .. "," .. id.id .. "," .. id.eid
	end
	return table.concat(parts, "|")
end

function map.pickSpawn(clients)
	for _, point in ipairs(map.spawns) do
		local free = true
		for _, ports in pairs(clients) do
			for _, data in pairs(ports) do
				if math.abs(data.x - point[1]) < 24 and math.abs(data.y - point[2]) < 24 then
					free = false
				end
			end
		end
		if free then return point[1], point[2] end
	end
	return map.spawns[#map.spawns][1], map.spawns[#map.spawns][2]
end

return map
