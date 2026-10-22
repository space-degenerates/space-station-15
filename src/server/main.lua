local socket = require("socket")
local logging = require("core.logging")
local commands = require("server.commands")
local packets = require("server.packets")
local map = require("server.map")

local logger = logging.logger("Server.Main", logging.colors.magenta)

local server = {}

local udp
local clients = {}

local debug
local consoleChannel

function server:init()
	udp = socket.udp()
	udp:settimeout(0)
    udp:setsockname("0.0.0.0", 22122)

    map.load("station")

    love.thread.newThread("server/consolereader.lua"):start()
    consoleChannel = love.thread.getChannel("console")

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
        for port in next, ports do
            if not (ip == exIp and port == exPort) then
                udp:sendto(message .. "\n", ip, port)
            end
        end
    end
end

function love.update(delta)
    if not server.started then return end

    local line = consoleChannel:pop()
    while line do
        commands.handle(line, server, clients, logger)
        line = consoleChannel:pop()
    end

    local data, ip, port = udp:receivefrom()
    while data do
        data = data:gsub("\n", "")

    	if debug then logger:log(string.format("%s:%d -> %s", ip, port, data)) end
    	packets.handle(data, ip, port, server, clients, logger)

    	data, ip, port = udp:receivefrom()
    end

    love.timer.sleep(0.01)
end

function server:run(debugwegot)
	--require("@core/module")()
	debug = (debugwegot == "--debug") and true or false
	server:init()
	server.started = true
end

function love.quit()
    for ip, ports in next, clients do
        for port in next, ports do
            server:sendTo(ip, port, "SERVER_CLOSE|Server shutting off.")
        end
    end
end

--function love.draw() end

return server
