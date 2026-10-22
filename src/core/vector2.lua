---@class engine.vector2
---@field x number
---@field y number
---@field magnitude number
local Vector2 = {}
Vector2.__index = Vector2

---@param x number?
---@param y number?
---@return engine.vector2
function Vector2.new(x, y)
	---@class engine.vector2
	local self = setmetatable({}, Vector2)
	self.x = x or 0
    self.y = y or 0
	self.magnitude = math.sqrt(self.x^2 + self.y^2)

	return self
end

---Multiply Point by a point or a number
---@param target number|engine.vector2
---@return engine.vector2
function Vector2:Mul(target)
    return Vector2.new(self.x * target.x, self.y * target.y)
end

---@param target engine.vector2
---@return engine.vector2
function Vector2:Sub(target)
    return Vector2.new(self.x - target.x, self.y - target.y)
end

---@param target engine.vector2
---@return engine.vector2
function Vector2:Sum(target)
    return Vector2.new(self.x + target.x, self.y + target.y)
end

function Vector2:Clone()
    return Vector2.new(self.x, self.y)
end

Vector2.ZERO = Vector2.new(0, 0)
Vector2.ONE = Vector2.new(1, 1)
Vector2.HALF = Vector2.new(.5, .5)

return Vector2
