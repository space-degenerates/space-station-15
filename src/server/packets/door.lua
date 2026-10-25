local doorBehavior = require("core.colliderbehaviors.door")
return function(content, ip, port, server, clients)
    print(content)
    doorBehavior({tonumber(content)})
end
