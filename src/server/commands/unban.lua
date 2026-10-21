return function(args, server, clients, logger)
	if server.banned and server.banned[args] then
		server.banned[args] = nil
		logger:log(args .. " was unbanned")
	else
		logger:log(args .. " is not banned")
	end
end
