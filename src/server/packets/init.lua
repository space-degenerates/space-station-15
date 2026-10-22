local packets = {}

function packets.handle(data, ip, port, server, clients, logger)
	local command, content = data:match("^([%w_]+)|?(.*)$")
	if not command then return end
	if not love.filesystem.getInfo("server/packets/" .. command:lower() .. ".lua") then return end

	require("server.packets." .. command:lower())(content, ip, port, server, clients, logger)
end

return packets
