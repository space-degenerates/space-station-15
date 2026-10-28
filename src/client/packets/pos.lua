local vector2 = require "core.vector2"
return function(content)
	local name, x, y, dir = content:match("^(.-)|(.-)|(.-)|(.*)$")
	local entity = Client.players[name]
	if not entity then return end

	entity:get("transform").pos = vector2.new(x, y)
	entity:get("sprite").direction = dir
end
