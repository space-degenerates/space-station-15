local vector2 = require("core.vector2")

local Transform = {}
Transform.__index = Transform

function Transform.new(entity, data)
	local self = setmetatable({}, Transform)
	self.pos = vector2.new(data.x, data.y)
	return self
end

return Transform
