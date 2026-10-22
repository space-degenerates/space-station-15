return function(content, client)
	local name, x, y = content:match("^(.-)|(.-)|(.*)$")
	client.players[name].x = x
    client.players[name].y = y
    client.players[name].tag.x = x
	client.players[name].tag.y = y - 20
end
