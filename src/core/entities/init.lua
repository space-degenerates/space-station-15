local entities = {}

function entities.spawn(id, x, y, forceId)
	if not love.filesystem.getInfo("core/entities/" .. id .. ".lua") then return end
	return require("core.entities." .. id)(x, y, forceId)
end

return entities
