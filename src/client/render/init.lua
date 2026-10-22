local vector2 = require "core.vector2"
local logging = require "core.logging"
local logger = logging.logger("[Render.Init]", logging.colors.green)

---@class engine.camera: engine.vector2
local camera = vector2.new(0, 0)
camera.zoom = 1
camera.canvas = love.graphics.newCanvas(1280, 720)
camera.objects = {}
camera.logger = logger

function camera:update(dt)
    local winW, winH = love.graphics.getDimensions()
    camera.scale = math.min(winW / 1280, winH / 720)
    camera.offsetX = (winW - 1280 * camera.scale) / 2
    camera.offsetY = (winH - 720 * camera.scale) / 2

    for _, object in next, camera.objects do
        if object.Update then
            object:Update(dt)
        end
    end
end

function camera:draw()
    love.graphics.setCanvas(camera.canvas)
    love.graphics.clear(.5,.5,.5)
    logger:log(string.format("inserted, count = %s", #camera.objects))

    for i, object in next, camera.objects do
        object:Draw(-1280/2 + camera.x, -720/2 + camera.y)
    end

    love.graphics.setCanvas()

    love.graphics.draw(self.canvas, camera.offsetX, camera.offsetY, 0, camera.scale * camera.zoom, camera.scale * camera.zoom)
end

return camera
