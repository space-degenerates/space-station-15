return function(content, client)
	local x, y = content:match("^(.-)|(.*)$")
	client.spawnX, client.spawnY = x, y

	if client.character then
		local pos = client.character:get("transform").pos
		pos.x, pos.y = x, y
		client.tag.x, client.tag.y = x, y - 15
	end
end
