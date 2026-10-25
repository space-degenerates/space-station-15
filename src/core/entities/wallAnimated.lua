local entity = require("core.entity")

return function(x, y, forceId)
	local ent = entity.new(forceId)
	ent.tile = true
	ent:add("transform", { x = x, y = y })
	ent:add("sprite", { texture = "core/textures/AnimatedTest.png", size = 32, frames = 6, fps = 15, fpr = 6})
	ent:add("collider", { w = 32, h = 32 })
	return ent
end
