local entity = require("core.entity")

return function(x, y)
	local ent = entity.new()
	ent:add("transform", { x = x, y = y })
	ent:add("sprite", { texture = "core/textures/CatTest2.png", directions = true })
	ent:add("collider", { w = 24, h = 24 })
	return ent
end
