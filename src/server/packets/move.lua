return function(content, ip, port)
	local player = Server.clients[ip] and Server.clients[ip][port]
	if not player then return end

	local x, y, dir = content:match("^(.-)|(.-)|(.*)$")
	player.x = x
	player.y = y
	player.dir = dir
	Server:sendAllExcept(ip, port, string.format("POS|%s|%f|%f|%s", player.name, player.x, player.y, player.dir))
end
