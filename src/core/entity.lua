local Entity = {}
Entity.__index = Entity

function Entity.new()
	local self = setmetatable({}, Entity)
	self.components = {}
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

return Entity
