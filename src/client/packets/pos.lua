return function(content, client)
	local name, x, y, dir = content:match("^(.-)|(.-)|(.-)|(.*)$")
	local entity = client.players[name]
	if not entity then return end

	entity:get("transform").pos.x = x
	entity:get("transform").pos.y = y
	entity:get("sprite").direction = dir
	entity.tag.x = x
	entity.tag.y = y - 20
end
