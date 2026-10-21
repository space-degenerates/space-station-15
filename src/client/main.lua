local point = require("core.point")
local render = require("core.render")
local socket = require("socket")
local logging = require("core.logging")

local logger = logging.logger("Client.Main", logging.colors.blue)

local client = {}

local udp
local connected = false

local connectionText = render.text("Connecting... (Attempt 1)", point.point(0, 0), 5, 1, render.defaultFont, render.color(1, 1, 1, 1), point.point(.5, .5))

function client.init(ip)
	udp = socket.udp()
	udp:settimeout(.1)
	udp:setpeername(ip, 22122)
end

function client.send(message)
	logger:log(string.format("Sending Message {%s} to server", message))
	udp:send(message .. "\n")
end

function client.receive()
	--logger:log("Checking for incoming server messages")
	local data, _, _ = udp:receive()
	--logger:log(data, msg)
	if data then
		logger:log(string.format("Server sent data {%s}", data))
		return data:gsub("\n", "")
	end
	return nil
end
local attemptCount = 0
function client.tryConnect()
	attemptCount = attemptCount + 1
	client.send("CONNECT")
end

function client.run(ip)
	client.init(ip)
	local lastAttempt = 0

	lastAttempt = socket.gettime()
	client.tryConnect()

	function love.update(dt)
		local data = client.receive()
		if data then
			logger:log(string.format("Recive: %s", data))

			local prefix, content = data:match("^(%w+)|(.+)$")

			if prefix == "WELCOME" then
				connected = true
				logger:log("Connected to server")
				connectionText.text = "Connected to the server."
			elseif prefix == "SPACE_CONFIRM" then
				logger:log(content)
			elseif prefix == "SERVER_CLOSE" then
				logger:log(content)
				connected = false
				connectionText.text = "Connecting... (Attempt 1)"
				lastAttempt = socket.gettime()
			end
		end

		if not connected then
			local currentTime = socket.gettime()
			if currentTime - lastAttempt >= 2 then
				client.tryConnect()
				lastAttempt = currentTime
				connectionText.text = "Connecting... (Attempt "..attemptCount..")"
			end
		end

		render.update(dt)
	end

	function love.draw()
		love.graphics.clear(0, 0, 0)
		render.draw()
	end

	function love.keypressed(key)
		logger:log(key.." pressed")
		if key == "space" and connected then
			logger:log("Space pressed, send this to server")
			client.send("SPACE")
		end
	end
end

return client
