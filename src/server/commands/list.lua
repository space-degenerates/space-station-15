return function(args, server, clients, logger)
	for ip, ports in next, clients do
		for port, data in next, ports do
			logger:log(data.name .. " (" .. ip .. ":" .. port .. ")")
		end
	end
end
