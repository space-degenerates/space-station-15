local Entity = {}
Entity.__index = Entity
local EntityCount = 0

function Entity.new()
	local self = setmetatable({}, Entity)
    self.components = {}
    EntityCount = EntityCount + 1
	self.id = EntityCount
	return self
end

function Entity:add(name, data)
	self.components[name] = require("core.components." .. name).new(self, data)
end

function Entity:get(name)
	return self.components[name]
end

function Entity:Draw(ox, oy)
	for _, component in pairs(self.components) do
		if component.Draw then component:Draw(ox, oy) end
	end
end

function Entity:Update(delta)
    for _, component in pairs(self.components) do
		if component.Update then component:Update(delta) end
	end
end

return Entity
