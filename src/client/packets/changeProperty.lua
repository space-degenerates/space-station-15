local entity   = require "core.entity"

return function(content)
    local id, property, value, component = content:match("^(.-)|(.-)|(.-)|(.*)$")

    print(#entity.entities, id)
    local ent = entity.entities[tonumber(id)]
    if value == "true" then
        value = true
    elseif value == "false" then
        value = false
    end
    if component then
        ent:get(component)[property] = tonumber(value) or value
    else
        ent[property] = tonumber(value) or value
    end
end
