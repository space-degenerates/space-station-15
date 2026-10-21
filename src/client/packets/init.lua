local packets = {}

function packets.handle(data, client, logger)
	local command, content = data:match("^([%w_]+)|?(.*)$")
	if not command then return end
	if not love.filesystem.getInfo("client/packets/" .. command:lower() .. ".lua") then return end

	require("client.packets." .. command:lower())(content, client, logger)
end

return packets
