local map = require("server.map")

return function(id, server, clients, logger)
	if not map.load(id) then
		logger:log("Map not found: " .. id)
		return
	end

	server:sendAll("MAP|" .. map.serialize())

	for ip, ports in pairs(clients) do
		for port, data in pairs(ports) do
			data.x, data.y = map.pickSpawn(clients)
			server:sendTo(ip, port, "TELEPORT|" .. data.x .. "|" .. data.y)
		end
	end

	for ip, ports in pairs(clients) do
		for port, data in pairs(ports) do
			server:sendAll(string.format("POS|%s|%d|%d|%s", data.name, data.x, data.y, data.dir))
		end
	end

	logger:log("Map changed to " .. id)
end
