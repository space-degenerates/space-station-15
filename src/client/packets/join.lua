local entities = require("core.entities")
local vector2 = require("core.vector2")
local text = require("client.render.text")
local render = require("client.render")

return function(content)
	local name, x, y, dir, proto, eid = content:match("^(.-)|(.-)|(.-)|(.-)|(.-)|(.*)$")
	local entity = entities.spawn(proto or "player", x, y, eid)
	entity:get("sprite").direction = dir
	entity:get("label").text = name

	table.insert(render.objects, entity)
	Client.players[name] = entity
end
