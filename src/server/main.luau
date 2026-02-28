local socket = require("socket")

local server = {}

local udp
local clients = {}

function server.init()
	udp = socket.udp()
	udp:settimeout(1)
	udp:setsockname("*", 22122)

	print(string.format("[Server] Listening on %s:%d", "127.0.0.1", 22122))
end

function server.sendTo(ip, port, message)
	udp:sendto(message .. "\n", ip, port)
end

function love.update()
	if server.started then
		print("Updating")
		local data, ip, port = udp:receivefrom()
		print(data, ip, port)

		if data then
			print(data)
			data = data:gsub("\n", "")

			if not clients[ip] then
				clients[ip] = port
				print(string.format("[Server] New client from %s:%d", ip, port))
				server.sendTo(ip, port, "WELCOME|Connected to server")
			end

			print(string.format("[Server] %s:%d -> %s", ip, port, data))
			print(os.date())
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

function love.draw() end

return server
