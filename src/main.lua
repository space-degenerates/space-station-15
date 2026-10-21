-- Only loads the base stuff based on what you're running

-- Running server uses the --server argument
-- argument 4 is username
-- For debug add --debug as 5 argument

if arg[2] == "--noexec" then
    if arg[3] == "--server" then
        require("server.main"):run(arg[4])
    else
        require("client.main"):run(arg[3], arg[4], arg[5])
    end
else
	if arg[1] == "--server" then
		require("server.main"):run(arg[2])
	else
		require("client.main"):run(arg[1], arg[2], arg[3])
	end
end
