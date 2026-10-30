local socket = require("socket")
local logging = require("core.logging")
local packets = require("client.packets")
local utf8 = require("utf8")
local entities = require("core.entities")
local collider = require("core.components.collider")
local vector2 = require("core.vector2")
local emath   = require("core.math")
local render = require("client.render")
local timer  = require("core.timer")

Client = {}
Client.connected = false
Client.players   = {}
Client.typing    = false
Client.chatMessage = ""
Client.logger = logging.logger("Client.Main", logging.colors.blue)
local debug
local udp

local font = love.graphics.getFont()
love.graphics.setDefaultFilter("nearest")

function Client:init(ip)
	udp = socket.udp()
	udp:settimeout(0)
    udp:setpeername(ip, 22122)
end

function Client:send(message)
    if debug then Client.logger:log(string.format("Sending Message {%s} to server", message)) end
	udp:send(message .. "\n")
end

function Client:receive()
    local data, _, _ = udp:receive()
    if data then
        if debug then Client.logger:log(string.format("Server sent data {%s}", data)) end
        return data:gsub("\n", "")
    end
    return nil
end

local attemptCount = 0
function Client:tryConnect()
	attemptCount = attemptCount + 1
	Client:send("CONNECT|" .. Client.username)
end

function Client:run(ip, usernameclient, debugwegot)
    print(debugwegot)
    debug = (debugwegot == "--debug") and true or false
    Client.debug = debug
    Client.username = usernameclient

    local input = ""
    local step = (ip and Client.username) and 3 or 1


    love.keyboard.setTextInput(false)
    function love.textinput(t)
        if step < 3 and t ~= "|" then input = input .. t end
        if Client.typing then Client.chatMessage = Client.chatMessage..t end
    end

    function love.update(dt)
        if step < 3 then return end

        if Client.bannedAt then
        	if love.timer.getTime() - Client.bannedAt >= 3 then
        		udp:close()
        		Client.bannedAt = nil
        		Client.lastAttempt = nil
        		Client.players = {}
        		attemptCount = 0
        		ip = nil
        		input = ""
        		step = 2
        	end
        	return
        end

        if not Client.lastAttempt then
            Client:init(ip)
            Client.lastAttempt = socket.gettime()
            Client:tryConnect()
        end

        local data = Client:receive()
        while data do
            packets.handle(data)
            data = Client:receive()
        end

        if Client.bannedAt then return end

        if Client.connected then
            if not Client.loaded then
                local spawnX = Client.spawnX or 0
                local spawnY = Client.spawnY or 0

                Client.character = entities.spawn("player", spawnX, spawnY, Client.charId)
                Client.character:get("label").text = Client.username
                if Client.character == nil then
                    return Client.logger:error("Weird, char not spawn, hm")
                end
                table.insert(render.objects, Client.character)

                Client.loaded = true
            end

            local transform = Client.character:get("transform")
            local sprite = Client.character:get("sprite")

            local dx = (not Client.typing) and (love.keyboard.isDown("d", "right") and 1 or 0) - (love.keyboard.isDown("a", "left") and 1 or 0) or 0
            local dy = (not Client.typing) and (love.keyboard.isDown("s", "down") and 1 or 0) - (love.keyboard.isDown("w", "up") and 1 or 0) or 0

            if dx ~= 0 or dy ~= 0 then
                local speed = love.keyboard.isDown("lshift") and 50 or 150
                local moveVector = vector2.new(dx, dy):Clamp(1)
                local nx = transform.pos.x + moveVector.x * dt * speed
                local ny = transform.pos.y + moveVector.y * dt * speed

                if not collider.blocked(Client.character, nx, transform.pos.y, render.objects) then
                    transform.pos.x = nx
                end
                if not collider.blocked(Client.character, transform.pos.x, ny, render.objects) then
                    transform.pos.y = ny
                end

                if dx > 0 then
                    sprite.direction = "east"
                elseif dx < 0 then
                    sprite.direction = "west"
                elseif dy > 0 then
                    sprite.direction = "south"
                elseif dy < 0 then
                    sprite.direction = "north"
                end

                Client:send(string.format("MOVE|%f|%f|%s", transform.pos.x, transform.pos.y, sprite.direction))
            end

            local t = math.min(1, dt * 8)
            render.x = emath.lerp(render.x, transform.pos.x, t)
            render.y = emath.lerp(render.y, transform.pos.y, t)
        elseif socket.gettime() - Client.lastAttempt >= 2 then
            Client:tryConnect()
            Client.lastAttempt = socket.gettime()
        end

        timer.update(dt)

        render:update(dt)
    end

    function love.draw()
        local w, h = love.graphics.getDimensions()

        if Client.bannedAt then
            love.graphics.print(Client.message, w / 2 - font:getWidth(Client.message) / 2, h / 2 - font:getHeight() / 2)
            return
        end

        if step < 3 then
            local text = (step == 1 and "Username: " or "IP: ") .. input .. "_"
            love.graphics.print(text, w / 2 - font:getWidth(text) / 2, h / 2 - font:getHeight() / 2)
            return
        end

        if not Client.connected then
            local text = string.format("Connecting... (Attempt %s)", attemptCount)
            love.graphics.print(text, w / 2 - font:getWidth(text) / 2, h / 2 - font:getHeight() / 2)
            return
        end

        -- character:Draw()
        -- love.graphics.rectangle("fill", x * (w - 20), y * (h - 20), 20, 20)
        -- love.graphics.print(username, x * (w - 20) + 10 - font:getWidth(username) / 2, y * (h - 20) - font:getHeight())

        -- for name, p in next, client.players do
        --     p.character:Draw()
        --     --love.graphics.rectangle("fill", p.x * (w - 20), p.y * (h - 20), 20, 20)
        --     love.graphics.print(name, p.x * (w - 20) + 10 - font:getWidth(name) / 2, p.y * (h - 20) - font:getHeight())
        -- end
        render:draw()
    end

    function love.keypressed(key)
        if step < 3 then
            if key == "backspace" then
                local offset = utf8.offset(input, -1)
                if offset then input = input:sub(1, offset - 1) end
            elseif key == "v" and love.keyboard.isDown("lctrl", "rctrl") then
                input = input .. (love.system.getClipboardText() or ""):gsub("[|\r\n]", "")
            elseif key == "return" and input ~= "" then
                if step == 1 then Client.username = input else ip = input end
                input = ""
                step = step + 1
            end
            return
        end

        --works with chat on so yeah
        if key == "return" then
            if Client.typing then
                Client:send("CHAT|" .. Client.chatMessage)
                local chat = Client.character:get("chat")
                chat.text = Client.chatMessage
                chat.visible = true
                timer.new(3, function ()
                    chat.visible = false
                end, {}, "chat")
                Client.chatMessage = ""
                Client.typing = false
                love.keyboard.setTextInput(false)
            else
                Client.typing = true
                love.keyboard.setTextInput(true)
            end
        elseif key == "backspace" then
            Client.chatMessage = string.sub(Client.chatMessage, 1, string.len(Client.chatMessage) - 1)
        end

        if not Client.typing then
            --whatever that should not work with chat on
        end

        if debug then Client.logger:log(key .. " pressed") end
    end

    function love.quit()
        if not Client.connected then return end
        Client:send("EXIT")
    end
end

return Client
