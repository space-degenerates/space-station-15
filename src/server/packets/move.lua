return function(content, ip, port, server, clients)
	local player = clients[ip] and clients[ip][port]
	if not player then return end

	local x, y, dir = content:match("^(.-)|(.-)|(.*)$")
	player.x = x
	player.y = y
	player.dir = dir
	server:sendAllExcept(ip, port, string.format("POS|%s|%f|%f|%s", player.name, player.x, player.y, player.dir))
end
