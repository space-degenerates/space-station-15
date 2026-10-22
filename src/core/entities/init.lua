local entities = {}

function entities.spawn(id, x, y)
	if not love.filesystem.getInfo("core/entities/" .. id .. ".lua") then return end
	return require("core.entities." .. id)(x, y)
end

return entities
