local entity = require("core.entity")
local vector2= require("core.vector2")

return function(x, y, forceId)
	local ent = entity.new(forceId)
	ent:add("transform", { x = x, y = y })
	ent:add("sprite", { texture = "core/textures/CatTest2.png", directions = true, layer = 1 })
    ent:add("collider", { w = 24, h = 24 })
    ent:add("text", { text = "", layer = 2, position = vector2.new(0, 20) }, "label")
    ent:add("text", { text = "", layer = 1, position = vector2.new(0, 30), visible = false }, "chat")
	ent.layer = 2
	return ent
end
