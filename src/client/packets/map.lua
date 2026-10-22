local entities = require("core.entities")
local render = require("client.render")

return function(content, client)
	for i = #render.objects, 1, -1 do
		if render.objects[i].tile then
			table.remove(render.objects, i)
		end
	end

	for tile in content:gmatch("([^|]+)") do
		local x, y, id = tile:match("^(.-),(.-),(.*)$")
		table.insert(render.objects, entities.spawn(id, x, y))
	end
end
