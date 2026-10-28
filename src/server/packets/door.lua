local doorBehavior = require("core.colliderbehaviors.door")
return function(content, ip, port)
    doorBehavior({tonumber(content)})
end
