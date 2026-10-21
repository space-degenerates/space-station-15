-- Only loads the base stuff based on what you're running

-- Running server uses the --server argument

local server = require("server.main")
local client = require("client.main")

if arg[2] == "--noexec" then
	if arg[3] == "--server" then
		server.run()
	else
		client.run(arg[3])
	end
else
	if arg[1] == "--server" then
		server.run()
	else
		client.run(arg[1])
	end
end
