local image = require "client.render.image"
local vector2 = require "core.vector2"
local text    = require "client.render.text"
return function(content, client)
	local name, x, y = content:match("^(.-)|(.-)|(.*)$")
    client.players[name] = image.new("resources/CatTest2.png", vector2.new(x, y))
	client.players[name].tag = text.new(name, vector2.new(x, y - 20))
end
