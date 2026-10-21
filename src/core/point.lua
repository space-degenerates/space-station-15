local vector = {}

---@class engine.vector2
---@field x number
---@field y number
local VectorClass = {}
VectorClass.__index = VectorClass

---@param x number?
---@param y number?
---@return engine.vector2
function vector.vector(x, y)
	---@class engine.vector2
	local self = setmetatable({}, VectorClass)
	self.x = x or 0
    self.y = y or 0
	self.magnitude = math.sqrt(self.x^2 + self.y^2)

	return self
end

---Multiply Point by a point or a number
---@param target number|engine.vector2
---@return engine.vector2
function VectorClass:Mul(target)
    return vector.vector(self.x * target.x, self.y * target.y)
end

---@param target engine.vector2
---@return engine.vector2
function VectorClass:Sub(target)
    return vector.vector(self.x - target.x, self.y - target.y)
end

---@param target engine.vector2
---@return engine.vector2
function VectorClass:Sum(target)
    return vector.vector(self.x + target.x, self.y + target.y)
end

return vector
