return function(content)
	Client.logger:log(content)
	Client.connected = false
	Client.bannedAt = love.timer.getTime()
	Client.message = content
end
