local Transform = {}
Transform.__index = Transform

function Transform.new(entity, data)
	local self = setmetatable({}, Transform)
	self.x = data.x or 0
	self.y = data.y or 0
	return self
end

return Transform
