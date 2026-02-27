local physics = {}

physics.world = love.physics.newWorld(0, 10)

---Make a new physics body from an object
---@param object any
---@param type love.BodyType
---@param shape love.Shape
---@param density number?
function physics.body(object, shape, type, density, friction)
	local newBody = love.physics.newBody(physics.world, object.position.x, object.position.y, type)
	object.body = newBody
	object.shape = shape
	newBody:setFixedRotation(true)

	object.fixture = love.physics.newFixture(object.body, shape, density)
	newBody:setPosition(object.position.x, object.position.y)
	object.fixture:setFriction(friction or 1)
end

return physics
