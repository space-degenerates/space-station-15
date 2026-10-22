return function(username, ip, port, server, clients, logger)
    if server.banned and server.banned[ip] then
    	server:sendTo(ip, port, "BANNED|You are banned from this server")
    	return
    end
	if not (clients[ip] and clients[ip][port]) then
		for _, ports in next, clients do
			for _, data in next, ports do
				if data.name == username then
					server:sendTo(ip, port, "NAME_TAKEN|Username is already in use")
					return
				end
			end
		end

		for _, ports in next, clients do
			for _, data in next, ports do
				server:sendTo(ip, port, string.format("JOIN|%s|%f|%f|%s|%s", data.name, data.x, data.y, data.dir, data.proto))
			end
		end

		clients[ip] = clients[ip] or {}
		clients[ip][port] = {name = username, x = .5, y = .5, dir = "south", proto = "player"}

		logger:log(string.format("%s connected from %s:%d", username, ip, port))
		server:sendAllExcept(ip, port, "PLAYER_EVENT|" .. username .. " connected to the server")
		server:sendAllExcept(ip, port, string.format("JOIN|%s|.5|.5|south|player", username))
	end

	server:sendTo(ip, port, "WELCOME|Connected to server")
end
