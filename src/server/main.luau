local socket = require("socket")
local logging = require("@core/logging")

local logger = logging.logger("Server.Main", logging.colors.magenta)

local server = {}

local udp
local clients = {}

function server.init()
	udp = socket.udp()
	udp:settimeout(.1)
	udp:setsockname("*", 22122)

	logger:log(string.format("Listening on %s:%d", "127.0.0.1", 22122))
end

function server.sendTo(ip, port, message)
	udp:sendto(message .. "\n", ip, port)
end

function love.update()
	if server.started then
		local data, ip, port = udp:receivefrom()

		if data then
			data = data:gsub("\n", "")

			if not clients[ip] then
				clients[ip] = port
				logger:log(string.format("New client from %s:%d", ip, port))
				server.sendTo(ip, port, "WELCOME|Connected to server")
			end

			logger:log(string.format("%s:%d -> %s", ip, port, data))
			logger:log(os.date())
			if data == "SPACE" then
				server.sendTo(
					ip,
					port,
					"SPACE_CONFIRM|Client " .. ip .. ":" .. port .. " pressed SPACE at " .. os.date("%H:%M:%S")
				)
			end
		end
		socket.sleep(0.1)
	end
end

function server.run()
	require("@core/module")()
	server.init()
	server.started = true
end

function love.quit()
	for ip, port in next, clients do
		server.sendTo(ip, port, "SERVER_CLOSE|Server shutting off.")
	end
end

function love.draw() end

return server
