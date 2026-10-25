local timer = require("core.timer")
return function(properties, ent1, ent2)
    if Client then
        local door = ent1.id
        print("door", door)
        Client:send(string.format("DOOR|%s", door))
    else

    -- local collider = ent1:get("collider")
    -- collider.canBehavior = false
    -- local sprite = ent1:get("sprite")
    -- timer.new(.5, function()
    --     print("evil1")
    --     collider.enabled = false
    --     sprite.visible = false
    --     timer.new(properties.duration or 4, function()
    --         print("evil2")
    --         collider.enabled = true
    --         sprite.visible = true
    --         collider.canBehavior = true
    --     end)
    -- end)

        local door = properties[1]
        print(door)

        Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s", door,"canBehavior","false", "collider"))
        timer.new(.3, function ()
            Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s",door,"enabled","false", "collider"))
            Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s", door, "visible", "false", "sprite"))
            timer.new(3, function ()
                Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s",door,"enabled","true", "collider"))
                Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s", door, "visible", "true", "sprite"))
                Server:sendAll(string.format("CHANGEPROPERTY|%s|%s|%s|%s", door, "canBehavior", "true", "collider"))
            end)
        end)
    end
end
