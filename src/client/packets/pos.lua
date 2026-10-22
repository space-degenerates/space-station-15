return function(content, client)
	local name, x, y = content:match("^(.-)|(.-)|(.*)$")
	client.players[name] = {x = tonumber(x), y = tonumber(y)}
end
