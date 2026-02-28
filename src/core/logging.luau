local logging = {}

logging.colors = {
	black = "\27[30m",
	red = "\27[31m",
	green = "\27[32m",
	yellow = "\27[33m",
	blue = "\27[34m",
	magenta = "\27[35m",
	cyan = "\27[36m",
	white = "\27[37m",
	default = "\27[0m"
}

function logging.dump(o)
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

function logging.gettime(): string
	return os.date("%Y-%m-%d %H:%M:%S")
end

local LoggerClass = {}
LoggerClass.__index = LoggerClass

--[[
	Creates a new logger.

	@param name Usually stands for the file name
	@param color ASCII color for the logger name. Can get grabbed from logging.colors table.
]]
function logging.logger(name, color)
	local logger = setmetatable({}, LoggerClass)

	logger.name = name
	logger.color = color

	return logger
end

function LoggerClass:log(info)
	print(string.format("%s [ %s%s%s ]: \27[32m%s\27[0m", logging.gettime(), self.color, self.name, logging.colors.default, info))
end

function LoggerClass:warn(info)
	print(string.format("%s [ %s%s%s ]: \27[33m%s\27[0m", logging.gettime(), self.color, self.name, logging.colors.default, info))
end

function LoggerClass:error(info)
	print(string.format("%s [ %s%s%s ]: \27[31m%s\27[0m", logging.gettime(), self.color, self.name, logging.colors.default, info))
end

return logging
