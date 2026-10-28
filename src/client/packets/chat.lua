local timer  = require("core.timer")

return function(content)
    local name, message = content:match("^(.-)|(.*)$")
    local player = Client.players[name]
    local chat = player:get("chat")
    chat.text = message
    chat.visible = true
    timer.new(3, function ()
        chat.visible = false
    end, {}, "chat")
end
