return function(content, ip, port, logger)
	if Server.clients[ip] and Server.clients[ip][port] then
		local name = Server.clients[ip][port].name
		Server.clients[ip][port] = nil
		if next(Server.clients[ip]) == nil then Server.clients[ip] = nil end

		Server:sendAll("LEAVE|" .. name)
		Server:sendAll("PLAYER_EVENT|" .. name .. " left the server")
		logger:log(name .. " has left the server")
	end
end
