local Collider = {}
Collider.__index = Collider

function Collider.new(entity, data)
	local self = setmetatable({}, Collider)
	self.w = data.w or 32
	self.h = data.h or 32
	return self
end

function Collider.blocked(entity, x, y, list)
	local c = entity:get("collider")
	for _, obj in ipairs(list) do
		if obj.get and obj.tile then
			local wall = obj:get("collider")
			if wall then
				local pos = obj:get("transform").pos
				if x - c.w / 2 < pos.x + wall.w / 2 and x + c.w / 2 > pos.x - wall.w / 2 and y - c.h / 2 < pos.y + wall.h / 2 and y + c.h / 2 > pos.y - wall.h / 2 then
					return true
				end
			end
		end
	end
	return false
end

return Collider
