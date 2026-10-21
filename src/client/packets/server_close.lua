local socket = require("socket")

return function(content, client, logger)
	logger:log(content)
	client.connected = false
	client.lastAttempt = socket.gettime()
end
