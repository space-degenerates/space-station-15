
return function(content)
    Client.connected = true
    Client.charId = tonumber(content)
	Client.logger:log("Connected to server")
end
