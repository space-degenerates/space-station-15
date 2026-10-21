return function(args, server, clients, logger)
	for ip, ports in next, clients do
		for port, data in next, ports do
			if data.name == args then
			    server:sendTo(ip, port, "KICKED|You were kicked from the server")
				clients[ip][port] = nil
				if next(clients[ip]) == nil then clients[ip] = nil end
				server:sendAll("LEAVE|" .. args)
				logger:log("Kicked " .. args)
				return
			end
		end
	end
	logger:log("Player not found: " .. args)
end
