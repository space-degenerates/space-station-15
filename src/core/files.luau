local json = require("@self/json")
local logging = require("@core/logging")

local logger = logging.logger("Core.Files", logging.colors.cyan)

local files = {}

function files.read(path)
	local file = io.open(path, "rb")
	if file then
		local content = file:read("*a")
		file:close()
		return content
	end
	logger:warn(string.format("File at path [%s] does not exist", path))
	return
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
