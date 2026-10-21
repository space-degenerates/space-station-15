return function(content, ip, port, server, clients, logger)
	if clients[ip] and clients[ip][port] then
		local name = clients[ip][port].name
		clients[ip][port] = nil
		if next(clients[ip]) == nil then clients[ip] = nil end

		server:sendAll("LEAVE|" .. name)
		server:sendAll("PLAYER_EVENT|" .. name .. " left the server")
		logger:log(name .. " has left the server")
	end
end
