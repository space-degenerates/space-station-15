return function(content, client, logger)
	logger:log(content)
	client.connected = false
	client.bannedAt = love.timer.getTime()
	client.message = content
end
