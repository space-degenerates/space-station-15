local vector2 = require "core.vector2"
local render = require("client.render")

---@class engine.image: engine.vector2
local ImageClass = {}
ImageClass.__index = ImageClass

---Creates a new Image
---@param path string
---@param position engine.vector2
---@param size engine.vector2?
---@param rotation number?
---@param anchor engine.vector2?
---@return engine.image
function ImageClass.new(path, position, size, rotation, anchor)
    local self = position:Clone()
    setmetatable(self, ImageClass)
    ---@cast self engine.image

    self.image = love.graphics.newImage(path)
    self.size = size or vector2.ONE:Clone()
    self.anchor = anchor or vector2.HALF:Clone()
    self.rotation = rotation or 0
    table.insert(render.objects, self)

    return self
end

function ImageClass:Draw(ox, oy)
    ox = ox or 0; oy = oy or 0

    local sx, sy = self.image:getDimensions()

    love.graphics.draw(self.image, self.x - ox - sx * self.anchor.x, self.y - oy - sy * self.anchor.y, self.rotation, self.size.x, self.size.y)
end

return ImageClass
