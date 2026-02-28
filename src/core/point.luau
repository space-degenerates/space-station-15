local point = {}

---@class engine.point
---@field x number
---@field y number
local PointClass = {}
PointClass.__index = PointClass

---@param x number?
---@param y number?
---@return engine.point
function point.point(x, y)
	---@class engine.point
	local self = setmetatable({}, PointClass)
	self.x = x or 0
	self.y = y or 0

	return self
end

---Multiply Point by a point or a number
---@param point number|engine.point
---@return engine.point
function PointClass:Mul(target)
	-- if engine.isOfClass(target, PointClass) then
	return point.point(self.x * target.x, self.y * target.y)
	-- elseif classes.isOfClass(point, "number") then
	-- return Point(self.x * target, self.y * target)
	-- else
	-- return self
	-- end
end

return point

-- engine.classes.PointClass = PointClass
