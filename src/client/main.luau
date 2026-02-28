local render = require("@core/render")
local socket = require("socket")

local client = {}

local udp
local connected = false

function client.init()
	udp = socket.udp()
	udp:settimeout(1)
	udp:setpeername("localhost", 22122)
end

function client.send(message)
	print(string.format("Sending Message {%s} to server", message))
	udp:send(message .. "\n")
end

function client.receive()
	print("Checking for incoming server messages")
	local data, msg, _ = udp:receive()
	print(data, msg)
	if data then
		print(string.format("Server sent data {%s}", data))
		return data:gsub("\n", "")
	end
	return nil
end
local attemptCount = 0
function client.tryConnect()
	attemptCount = attemptCount + 1
	client.send("CONNECT")
end

function client.draw()
	if connected then
		love.graphics.print("Connected, press space", 10, 10)
	else
		love.graphics.print(string.format("Wait for server (attempt %d)", attemptCount), 10, 10)
	end
end

function client.keypressed(key)
	if key == "space" and connected then
		print("[Client] Space pressed, send this to server")
		client.send("SPACE")
	end
end

function client.run()
	require("@core/module")()
	client.init()
	local lastAttempt = 0

	lastAttempt = socket.gettime()
	client.tryConnect()

	function love.update(dt)
		local data = client.receive()
		if data then
			print(string.format("[Client] Recive: %s", data))

			local prefix, content = data:match("^(%w+)|(.+)$")

			if prefix == "WELCOME" then
				connected = true
				print("[Client] Connected to server")
			elseif prefix == "SPACE_CONFIRM" then
				print(string.format("[Client] %s", content))
			end
		end

		if not connected then
			local currentTime = socket.gettime()
			if currentTime - lastAttempt >= 2 then
				client.tryConnect()
				lastAttempt = currentTime
			end
		end

		render.update(dt)
	end

	function love.draw()
		love.graphics.clear(0, 0, 0)
		client.draw()
		render.draw()
	end

	function love.keypressed(key)
		client.keypressed(key)
	end
end

return client
