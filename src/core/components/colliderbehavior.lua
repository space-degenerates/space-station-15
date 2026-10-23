local timer = require("core.timer")

local ColliderBehavior = {}
ColliderBehavior.__index = ColliderBehavior

function ColliderBehavior.new(entity, data)
    local self = setmetatable({}, ColliderBehavior)

    self.type = data.type
    self.prop = data.properties
    self.canTrigger = true

	return self
end

function ColliderBehavior:collide(entity, curEntity)
    if not self.canTrigger then return end
    if self.type == "print" then
        print(string.format("Hi, %s collided", entity))
    elseif self.type == "door" then
        print(string.format("Hi, %s collided", entity))
        self.canTrigger = false

        timer.new(.5, function()
            print("evil1")
            curEntity:get("collider").enabled = false
            curEntity:get("sprite").visible = false
            timer.new(2, function()
                print("evil2")
                self.canTrigger = true
                curEntity:get("collider").enabled = true
                curEntity:get("sprite").visible = true
            end)
        end)
    end
end

return ColliderBehavior
