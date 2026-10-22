local entities = require("core.entities")
local vector2 = require("core.vector2")
local text = require("client.render.text")
local render = require("client.render")

return function(content, client)
	local name, x, y, dir, proto = content:match("^(.-)|(.-)|(.-)|(.-)|(.*)$")
	local entity = entities.spawn(proto or "player", x, y)
	entity:get("sprite").direction = dir
	entity.tag = text.new(name, vector2.new(x, y - 20))

	table.insert(render.objects, entity)
	client.players[name] = entity
end
