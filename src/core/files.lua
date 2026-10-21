local json = require("core.json")

local files = {}

function files.read(path)
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*a")
		file:close()
		return content
	end
end

function files.write(path, content)
	local file = io.open(path, "w")
	if file then
		if type(content) == "table" then
			content = json.stringify(content)
		end

		file:write(content)
		file:close()
	end
end

return files
