local entities = require "core.entity"
return function(content, logger)
    Client.connected = true
    Client.charId = tonumber(content)
	logger:log("Connected to server")
end
