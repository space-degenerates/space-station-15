local timer = require("core.timer")
return function(properties, ent1, ent2)
    local collider = ent1:get("collider")
    collider.canBehavior = false
    local sprite = ent1:get("sprite")
    timer.new(.5, function()
        print("evil1")
        collider.enabled = false
        sprite.visible = false
        timer.new(properties.duration or 4, function()
            print("evil2")
            collider.enabled = true
            sprite.visible = true
            collider.canBehavior = true
        end)
    end)
end
