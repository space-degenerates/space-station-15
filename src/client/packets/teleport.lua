return function(content)
	local x, y = content:match("^(.-)|(.*)$")
	Client.spawnX, Client.spawnY = x, y

	if Client.character then
		local pos = Client.character:get("transform").pos
		pos.x, pos.y = x, y
		Client.tag.x, Client.tag.y = x, y - 15
	end
end
