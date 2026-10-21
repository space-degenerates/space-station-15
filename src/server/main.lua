local socket = require("socket")
local logging = require("core.logging")

local logger = logging.logger("Server.Main", logging.colors.magenta)

local server = {}

local udp
local clients = {}

local debug

function server:init()
	udp = socket.udp()
	udp:settimeout(.1)
	udp:setsockname("0.0.0.0", 22122)

	logger:log(string.format("Listening on %s:%d", "127.0.0.1", 22122))
end

function server:sendTo(ip, port, message)
    udp:sendto(message .. "\n", ip, port)
end

function server:sendAll(message)
    for ip, ports in next, clients do
        for port, data in next, ports do
            udp:sendto(message .. "\n", ip, port)
        end
    end
end

function server:sendAllExcept(exIp, exPort, message)
    for ip, ports in next, clients do
        for port, data in next, ports do
            if ip ~= exIp and port ~= exPort then
                udp:sendto(message .. "\n", ip, port)
            end
        end
    end
end

function love.update(delta)
	if server.started then
		local data, ip, port = udp:receivefrom()

		if data then
			data = data:gsub("\n", "")

			if not clients[ip] or not clients[ip][port] then
                clients[ip] = {}
				if not clients[ip][port] then
					clients[ip][port] = {}
				end
				logger:log(string.format("New client from %s:%d", ip, port))
				server:sendTo(ip, port, "WELCOME|Connected to server")
				server:sendAllExcept(ip, port, "PLAYER_EVENT|Client  connected to the server")
			end

			if debug then logger:log(string.format("%s:%d -> %s", ip, port, data)) end
			if debug then logger:log(os.date()) end
			if data == "SPACE" then
				server:sendAll("SPACE_CONFIRM|Client " .. ip .. ":" .. port .. " pressed SPACE at " .. os.date("%H:%M:%S"))
			elseif data == "EXIT" then
                clients[ip][port] = nil
                if #clients[ip] == 0 then
                    clients[ip] = nil
                end
                server:sendAll("PLAYER_EVENT|Client " .. ip .. ":" .. port .. " left the server")
                logger:log(string.format("%s%d has left the server", ip, port))
			end
		end
		socket.sleep(0.1)
	end
end

function server:run(debugwegot)
	--require("@core/module")()
	debug = (debugwegot == "--debug") and true or false
	server:init()
	server.started = true
end

function love.quit()
	for ip, port in next, clients do
		server:sendAll("SERVER_CLOSE|Server shutting off.")
	end
end

function love.draw() end

return server
