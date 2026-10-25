local vector2 = require "core.vector2"
local logging = require "core.logging"
local logger = logging.logger("[Render.Init]", logging.colors.green)

---@class engine.camera: engine.vector2
local camera = vector2.new(0, 0)
camera.zoom = 2
camera.canvas = love.graphics.newCanvas(1920, 1080)
camera.canvas:setFilter("nearest","nearest")
camera.objects = {}
camera.logger = logger

function camera:update(dt)
    local winW, winH = love.graphics.getDimensions()
    camera.scale = math.min(winW / 1920, winH / 1080) * camera.zoom
    camera.offsetX = (winW - 1920 * camera.scale) / 2
    camera.offsetY = (winH - 1080 * camera.scale) / 2

    for _, object in next, camera.objects do
        if object.Update then
            object:Update(dt)
        end
    end
end

function camera:draw()
    love.graphics.setCanvas(camera.canvas)
    love.graphics.clear(.5,.5,.5)
    --logger:log(string.format("inserted, count = %s", #camera.objects))

    for i, object in next, camera.objects do
        object:Draw(-1920 / 2 + camera.x, -1080 / 2 + camera.y)

        if Client.debug and object.get then
            local hasTrans = object:get("transform")
            if object.id and hasTrans  then
                --print("hasid lala", object.id)
                love.graphics.print(object.id, hasTrans.pos.x - (-1920 / 2 + camera.x), hasTrans.pos.y - (-1080 / 2 + camera.y) - 40)
            end
        end
    end

    love.graphics.setCanvas()

    love.graphics.draw(self.canvas, camera.offsetX, camera.offsetY, 0, camera.scale, camera.scale)
end

return camera
