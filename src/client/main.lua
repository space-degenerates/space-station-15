local point = require("core.point")
local socket = require("socket")
local logging = require("core.logging")
local packets = require("client.packets")
local utf8 = require("utf8")

local logger = logging.logger("Client.Main", logging.colors.blue)

local client = {}

local udp
client.connected = false
local username

client.players = {}
local x, y = .5, .5

local debug

local font = love.graphics.getFont()

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
            local dx = (love.keyboard.isDown("d", "right") and 1 or 0) - (love.keyboard.isDown("a", "left") and 1 or 0)
            local dy = (love.keyboard.isDown("s", "down") and 1 or 0) - (love.keyboard.isDown("w", "up") and 1 or 0)

            if dx ~= 0 or dy ~= 0 then
                x = math.min(1, math.max(0, x + dx * dt * .5))
                y = math.min(1, math.max(0, y + dy * dt * .5))
                client:send(string.format("MOVE|%f|%f", x, y))
            end
        elseif socket.gettime() - client.lastAttempt >= 2 then
            client:tryConnect()
            client.lastAttempt = socket.gettime()
        end
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

        love.graphics.rectangle("fill", x * (w - 20), y * (h - 20), 20, 20)
        love.graphics.print(username, x * (w - 20) + 10 - font:getWidth(username) / 2, y * (h - 20) - font:getHeight())

        for name, p in next, client.players do
            love.graphics.rectangle("fill", p.x * (w - 20), p.y * (h - 20), 20, 20)
            love.graphics.print(name, p.x * (w - 20) + 10 - font:getWidth(name) / 2, p.y * (h - 20) - font:getHeight())
        end
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
