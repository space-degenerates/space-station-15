local socket = require("socket")
local logging = require("core.logging")
local commands = require("server.commands")
local packets = require("server.packets")
local map = require("server.map")
local timer = require("core.timer")

local logger = logging.logger("Server.Main", logging.colors.magenta)

Server = {}

local udp
local clients = {}
Server.entityCount = 0

local debug
local consoleChannel

function Server:init()
	udp = socket.udp()
	udp:settimeout(0)
    udp:setsockname("0.0.0.0", 22122)

    map.load("station")

    love.thread.newThread("server/consolereader.lua"):start()
    consoleChannel = love.thread.getChannel("console")

	logger:log(string.format("Listening on %s:%d", "127.0.0.1", 22122))
end

function Server:sendTo(ip, port, message)
    udp:sendto(message .. "\n", ip, port)
end

function Server:sendAll(message)
    if debug then logger:log(message) end
    for ip, ports in next, clients do
        for port, data in next, ports do
            udp:sendto(message .. "\n", ip, port)
        end
    end
end

function Server:sendAllExcept(exIp, exPort, message)
    for ip, ports in next, clients do
        for port in next, ports do
            if not (ip == exIp and port == exPort) then
                udp:sendto(message .. "\n", ip, port)
            end
        end
    end
end

function love.update(delta)
    if not Server.started then return end

    local line = consoleChannel:pop()
    while line do
        commands.handle(line, Server, clients, logger)
        line = consoleChannel:pop()
    end

    local data, ip, port = udp:receivefrom()
    while data do
        data = data:gsub("\n", "")

        if debug then logger:log(string.format("%s:%d -> %s", ip, port, data)) end
        packets.handle(data, ip, port, Server, clients, logger)

        data, ip, port = udp:receivefrom()
    end
    timer.update(delta)

    love.timer.sleep(0.01)
end

function Server:run(debugwegot)
	--require("@core/module")()
	debug = (debugwegot == "--debug") and true or false
	Server:init()
	Server.started = true
end

function love.quit()
    for ip, ports in next, clients do
        for port in next, ports do
            Server:sendTo(ip, port, "Server_CLOSE|Server shutting off.")
        end
    end
end

--function love.draw() end

return Server
