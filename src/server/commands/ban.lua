return function(args, server, clients, logger)
	for ip, ports in next, clients do
		for port, data in next, ports do
			if data.name == args then
				server.banned = server.banned or {}
				server.banned[ip] = true

				server:sendTo(ip, port, "BANNED|You were banned from the server")
				ports[port] = nil
				if next(ports) == nil then clients[ip] = nil end

				server:sendAll("LEAVE|" .. args)
				logger:log(string.format("%s (%s) was banned", args, ip))
				return
			end
		end
	end

	logger:log("Player not found: " .. args)
end
