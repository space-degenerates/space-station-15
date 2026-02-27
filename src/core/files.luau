local json = require("@self/json")

local files = {}

function files.files.read(path)
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*a")
		file:close()
		return content
	end
end

function files.files.write(path, content)
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
