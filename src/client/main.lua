local point = require("core.point")
local socket = require("socket")
local logging = require("core.logging")

local logger = logging.logger("Client.Main", logging.colors.blue)

local client = {}

local udp
local connected = false

local debug

local font = love.graphics.getFont()

function client:init(ip)
	udp = socket.udp()
	udp:settimeout(.1)
	udp:setpeername(ip, 22122)
end

function client:send(message)
    if debug then logger:log(string.format("Sending Message {%s} to server", message)) end
	udp:send(message .. "\n")
end

function client:receive()
	--logger:log("Checking for incoming server messages")
	local data, _, _ = udp:receive()
	--logger:log(data, msg)
	if data then
		if debug then logger:log(string.format("Server sent data {%s}", data)) end
		return data:gsub("\n", "")
	end
	return nil
end
local attemptCount = 0
function client:tryConnect()
	attemptCount = attemptCount + 1
	client:send("CONNECT")
end

function client:run(ip, debugwegot)
    debug = (debugwegot == "--debug") and true or false
    client:init(ip)
    local lastAttempt = 0

    lastAttempt = socket.gettime()
    client:tryConnect()

    function love.update(dt)
        local data = client:receive()
        if data then
            logger:log(string.format("Recive: %s", data))

            local prefix, content = data:match("^(%w+)|(.+)$")

            if prefix == "WELCOME" then
                connected = true
                logger:log("Connected to server")
            elseif prefix == "SPACE_CONFIRM" then
                logger:log(content)
            elseif prefix == "SERVER_CLOSE" then
                logger:log(content)
                connected = false
                lastAttempt = socket.gettime()
            end
        end

        if not connected then
            local currentTime = socket.gettime()
            if currentTime - lastAttempt >= 2 then
                client:tryConnect()
                lastAttempt = currentTime
            end
        end
    end

    function love.draw()
        love.graphics.clear(0, 0, 0)
        local x, y = love.graphics.getDimensions()
        local text = connected and "Connected to server" or string.format("Connecting... (Attempt %s)",attemptCount)
        love.graphics.print(text, x / 2 - font:getWidth(text) / 2, y / 2 - font:getHeight() / 2)
    end

    function love.keypressed(key)
        if debug then logger:log(key .. " pressed") end
        if key == "space" and connected then
            logger:log("Space pressed, send this to server")
            client:send("SPACE")
        end
    end

    function love.quit()
        if not connected then return end

        client:send("EXIT")
	end
end

return client
