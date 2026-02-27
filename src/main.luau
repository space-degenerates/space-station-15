-- Only loads the base stuff based on what you're running

-- Running server uses the --server argument

local globals = require("@core/game")
local server = require("@server/main")
local client = require("@client/main")

if arg[1] == "server" or arg[2] == "server" then
	server.run()
	globals.server = true
else
	client.run()
	globals.server = false
end
