return function(content, ip, port, server, clients)
	local player = clients[ip] and clients[ip][port]
	if not player then return end

	local x, y = content:match("^(.-)|(.*)$")
	player.x = x
	player.y = y
	server:sendAllExcept(ip, port, string.format("POS|%s|%f|%f", player.name, player.x, player.y))
end
