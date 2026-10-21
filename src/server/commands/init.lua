local commands = {}

function commands.handle(line, server, clients, logger)
	local cmd, args = line:match("^(%S+)%s*(.*)$")
	if not cmd then return end
	local success, command = pcall(require, "server.commands." .. cmd)

	if not success then
		logger:log("Unknown command or load error: " .. cmd)
		return
	end

	if type(command) == "function" then
		command(args, server, clients, logger)
	end
end

return commands
