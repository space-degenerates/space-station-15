return function(args, server, clients, logger)
	server:sendAll("PLAYER_EVENT|[Server] " .. args)
	logger:log("Broadcast: " .. args)
end
