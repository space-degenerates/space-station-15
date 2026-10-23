local entity = require("core.entity")

return function(x, y)
	local ent = entity.new()
	ent.tile = true
	ent:add("transform", { x = x, y = y })
	ent:add("sprite", { texture = "core/textures/SomewhatKnownTexture.png", size = 32 })
	ent:add("collider", { w = 32, h = 32, behavior = "door", behaviorProp = {duration = 6} })
	return ent
end
