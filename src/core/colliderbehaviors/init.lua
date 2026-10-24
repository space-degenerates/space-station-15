local behaviors = {}

function behaviors.activate(id, properties, entity1, entity2)
	if not love.filesystem.getInfo("core/colliderbehaviors/" .. id .. ".lua") then return end
	return require("core.colliderbehaviors." .. id)(properties, entity1, entity2)
end

return behaviors
