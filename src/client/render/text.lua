local vector2 = require("core.vector2")
local render = require("client.render")
local etable = require("core.table")

---@class engine.text: engine.vector2
local TextClass = {}
TextClass.__index = TextClass
TextClass.DEFAULT = love.graphics.newFont()

---Creates a new Text object
---@param text string
---@param position engine.vector2
---@param font love.Font?
---@param anchor engine.vector2?
---@return engine.text
function TextClass.new(text, position, font, anchor)
    ---@class engine.text
    local self = position:Clone()
    setmetatable(self, TextClass)

    self.text = text
    self.font = font or TextClass.DEFAULT
    self.anchor = anchor or vector2.HALF:Clone()

    render.logger:log("Text, new text")

    table.insert(render.objects, self)

    return self
end

function TextClass:Draw(ox, oy)
    ox = ox or 0; oy = oy or 0

    local _, count = self.text:gsub("\n", "\n")

    local oox = self.font:getWidth(self.text) * self.anchor.x
    local ooy = self.font:getHeight() * (count + 1) * self.anchor.y

    love.graphics.print(self.text, self.x - ox - oox, self.y - oy - ooy)
end

return TextClass
