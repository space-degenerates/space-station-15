local vector2 = require("core.vector2")
local render = require("client.render")

local TextClass = {}
TextClass.__index = TextClass
TextClass.DEFAULT = love.graphics.newFont()

---@return engine.text
function TextClass.new(entity, data)
    ---@class engine.text
    local self = setmetatable({}, TextClass)

    self.text = data.text or ""
    self.font = data.font or TextClass.DEFAULT
    self.anchor = data.anchor or vector2.HALF:Clone()
    self.layer = data.layer or 1
    self.entity = entity
    self.entTransform = entity:get("transform")
    self.offset = data.position or vector2.new()
    self.visible = data.visible ~= nil and data.visible or true

    render.logger:log("Text, new text")

    return self
end

function TextClass:Draw(ox, oy)
    if not self.visible then return end
    ox = ox or 0; oy = oy or 0

    local _, count = self.text:gsub("\n", "\n")

    local oox = self.font:getWidth(self.text) * self.anchor.x
    local ooy = self.font:getHeight() * (count + 1) * self.anchor.y

    love.graphics.print(self.text, self.entTransform.pos.x - ox - oox - self.offset.x, self.entTransform.pos.y - oy - ooy - self.offset.y)
end

return TextClass
