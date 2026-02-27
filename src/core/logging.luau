local engine = require("@self/init")

local logging = {}

function engine.logging.dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. logging.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

return logging
