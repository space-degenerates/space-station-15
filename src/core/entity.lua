local EntitySystem = {}
EntitySystem.entities = {}

local Entity = {}
Entity.__index = Entity
local EntityCount = 0

function EntitySystem.new(forceId)
	local self = setmetatable({}, Entity)
    self.components = {}
    EntityCount = EntityCount + 1
    if forceId then
        print(forceId, "forceid")
        if EntitySystem[forceId] then
            local idx
            repeat
                idx = math.random(4000, 15000)
            until not EntitySystem.entities[idx]
            EntitySystem[idx] = EntitySystem[forceId]
        end
        self.id = forceId
        EntitySystem.entities[forceId] = self
        print(self.id, "id")
    else
        self.id = EntityCount
        EntitySystem.entities[self.id] = self
    end
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

return EntitySystem
