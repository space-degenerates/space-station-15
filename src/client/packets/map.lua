local entities = require("core.entities")
local render = require("client.render")

return function(content)
	for i = #render.objects, 1, -1 do
		if render.objects[i].tile then
			table.remove(render.objects, i)
		end
	end

	for tile in content:gmatch("([^|]+)") do
        local x, y, id, eid = tile:match("^(.-),(.-),(.-),(.*)$")
        print("eid", eid)
		print(content, "content")
		table.insert(render.objects, entities.spawn(id, x, y, tonumber(eid)))
	end
end
