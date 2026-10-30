local map = require("server.map")

return function(username, ip, port, logger)
    if Server.banned and Server.banned[ip] then
    	Server:sendTo(ip, port, "BANNED|You are banned from this server")
    	return
    end
	if not (Server.clients[ip] and Server.clients[ip][port]) then
		for _, ports in next, Server.clients do
			for _, data in next, ports do
				if data.name == username then
					Server:sendTo(ip, port, "NAME_TAKEN|Username is already in use")
					return
				end
			end
		end

        for _, ports in next, Server.clients do
            for _, data in next, ports do
                Server:sendTo(ip, port,
                    string.format("JOIN|%s|%f|%f|%s|%s|%s", data.name, data.x, data.y, data.dir, data.proto, data.eid))
            end
        end

		Server.entityCount = Server.entityCount + 1
		Server.clients[ip] = Server.clients[ip] or {}
		local x, y = map.pickSpawn(Server.clients)
        Server.clients[ip][port] = { name = username, x = x, y = y, dir = "south", proto = "player", eid = Server.entityCount }


		logger:log(string.format("%s connected from %s:%d", username, ip, port))
		Server:sendAllExcept(ip, port, "PLAYER_EVENT|" .. username .. " connected to the server")
		Server:sendAllExcept(ip, port, string.format("JOIN|%s|%d|%d|south|player|%s", username, x, y, Server.entityCount))
	end

	local player = Server.clients[ip][port]
	Server:sendTo(ip, port, "MAP|" .. map.serialize())
	Server:sendTo(ip, port, "TELEPORT|" .. player.x .. "|" .. player.y)
	Server:sendTo(ip, port, "WELCOME|Connected to server|"..player.eid)
end
