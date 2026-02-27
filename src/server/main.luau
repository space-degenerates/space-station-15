local server = {}

function server.run()
	print("Server")
	require("@core/module")()
end

return server
