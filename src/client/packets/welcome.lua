return function(content, client, logger)
	client.connected = true
	logger:log("Connected to server")
end
