return function(args, server, clients, logger)
	logger:log("Available commands:")
	for _, file in ipairs(love.filesystem.getDirectoryItems("server/commands")) do
		logger:log("  " .. file:gsub("%.lua$", ""))
	end
end
