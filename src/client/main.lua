local socket = require("socket")
local logging = require("core.logging")
local packets = require("client.packets")
local utf8 = require("utf8")
local entities = require("core.entities")
local collider = require("core.components.collider")
local vector2 = require("core.vector2")
local emath   = require("core.math")
local render = require("client.render")
local text   = require("client.render.text")
local timer  = require("core.timer")

local logger = logging.logger("Client.Main", logging.colors.blue)

local client = {}

local udp
client.connected = false
local username

client.players = {}

local character,tag
local debug

local font       = love.graphics.getFont()
love.graphics.setDefaultFilter("nearest")

function client:init(ip)
	udp = socket.udp()
	udp:settimeout(0)
    udp:setpeername(ip, 22122)
end

function client:send(message)
    if debug then logger:log(string.format("Sending Message {%s} to server", message)) end
	udp:send(message .. "\n")
end

function client:receive()
	local data, _, _ = udp:receive()
	if data then
		if debug then logger:log(string.format("Server sent data {%s}", data)) end
		return data:gsub("\n", "")
	end
	return nil
end
local attemptCount = 0
function client:tryConnect()
	attemptCount = attemptCount + 1
	client:send("CONNECT|" .. username)
end

function client:run(ip, usernameclient, debugwegot)
    debug = (debugwegot == "--debug") and true or false
    username = usernameclient

    local input = ""
    local step = (ip and username) and 3 or 1

    function love.textinput(t)
        if step < 3 and t ~= "|" then input = input .. t end
    end

    function love.update(dt)
        if step < 3 then return end

        if client.bannedAt then
        	if love.timer.getTime() - client.bannedAt >= 3 then
        		udp:close()
        		client.bannedAt = nil
        		client.lastAttempt = nil
        		client.players = {}
        		attemptCount = 0
        		x, y = .5, .5
        		ip = nil
        		input = ""
        		step = 2
        	end
        	return
        end

        if not client.lastAttempt then
            client:init(ip)
            client.lastAttempt = socket.gettime()
            client:tryConnect()
        end

        local data = client:receive()
        while data do
            packets.handle(data, client, logger)
            data = client:receive()
        end

        if client.bannedAt then return end

        if client.connected then
            if not client.loaded then
                local spawnX = client.spawnX or 0
                local spawnY = client.spawnY or 0

                character = entities.spawn("player", spawnX, spawnY)
                client.character = character
                table.insert(render.objects, character)
                tag = text.new(username, vector2.new(spawnX, spawnY - 15))
                client.tag = tag

                client.loaded = true
            end

            local transform = character:get("transform")
            local sprite = character:get("sprite")

            local dx = (love.keyboard.isDown("d", "right") and 1 or 0) - (love.keyboard.isDown("a", "left") and 1 or 0)
            local dy = (love.keyboard.isDown("s", "down") and 1 or 0) - (love.keyboard.isDown("w", "up") and 1 or 0)

            if dx ~= 0 or dy ~= 0 then
                local speed = love.keyboard.isDown("lshift") and 50 or 150
                local moveVector = vector2.new(dx, dy):Clamp(1)
                local nx = transform.pos.x + moveVector.x * dt * speed
                local ny = transform.pos.y + moveVector.y * dt * speed

                if not collider.blocked(character, nx, transform.pos.y, render.objects) then
                    transform.pos.x = nx
                end
                if not collider.blocked(character, transform.pos.x, ny, render.objects) then
                    transform.pos.y = ny
                end

                tag.x = transform.pos.x
                tag.y = transform.pos.y - 15

                if dx > 0 then
                    sprite.direction = "east"
                elseif dx < 0 then
                    sprite.direction = "west"
                elseif dy > 0 then
                    sprite.direction = "south"
                elseif dy < 0 then
                    sprite.direction = "north"
                end

                client:send(string.format("MOVE|%f|%f|%s", transform.pos.x, transform.pos.y, sprite.direction))
            end

            local t = math.min(1, dt * 8)
            render.x = emath.lerp(render.x, transform.pos.x, t)
            render.y = emath.lerp(render.y, transform.pos.y, t)
        elseif socket.gettime() - client.lastAttempt >= 2 then
            client:tryConnect()
            client.lastAttempt = socket.gettime()
        end

        timer.update(dt)

        render:update(dt)
    end

    function love.draw()
        local w, h = love.graphics.getDimensions()

        if client.bannedAt then
            love.graphics.print(client.message, w / 2 - font:getWidth(client.message) / 2, h / 2 - font:getHeight() / 2)
            return
        end

        if step < 3 then
            local text = (step == 1 and "Username: " or "IP: ") .. input .. "_"
            love.graphics.print(text, w / 2 - font:getWidth(text) / 2, h / 2 - font:getHeight() / 2)
            return
        end

        if not client.connected then
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
                if step == 1 then username = input else ip = input end
                input = ""
                step = step + 1
            end
            return
        end

        if debug then logger:log(key .. " pressed") end
    end

    function love.quit()
        if not client.connected then return end
        client:send("EXIT")
    end
end

return client
