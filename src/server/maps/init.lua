local maps = {}

function maps.load(id)
    if not love.filesystem.getInfo("server/maps/" .. id .. ".lua") then return end
	return require("server.maps." .. id)()
end

return maps
