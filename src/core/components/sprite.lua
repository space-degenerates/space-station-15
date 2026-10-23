local Sprite = {}
Sprite.__index = Sprite

local directions = { south = 1, north = 2, east = 3, west = 4 }

function Sprite.new(entity, data)
    local self = setmetatable({}, Sprite)
    self.entity = entity
    self.visible = true
    self.fps = data.fps
    self.frame = 1
    self.time = 0

    local ok = pcall(function()
        self.image = love.graphics.newImage(data.texture)
    end)
    if not ok then
        self.image = love.graphics.newImage("core/textures/UnknowTexture.png")
    end
    self.direction = data.direction or "south"
    self.size = data.size or 0

    local w, h = self.image:getDimensions()
    self.frameW, self.frameH = w, h
    if data.directions then
        self.frameW, self.frameH = w / 2, h / 2
        self.quads = {
            love.graphics.newQuad(0, 0, self.frameW, self.frameH, w, h),
            love.graphics.newQuad(self.frameW, 0, self.frameW, self.frameH, w, h),
            love.graphics.newQuad(0, self.frameH, self.frameW, self.frameH, w, h),
            love.graphics.newQuad(self.frameW, self.frameH, self.frameW, self.frameH, w, h),
        }
    elseif data.frames then
        self.frames = data.frames
        local rows = math.floor(data.frames / data.fpr)
        self.frameW = w / data.fpr
        self.frameH = h / rows
        self.animationQuads = {}
        for i = 1, data.frames do
            local row = math.floor(i / (data.fpr + 1))
            local thing = i - row * data.fpr
            print(thing * self.frameW, row * self.frameH)
            table.insert(self.animationQuads,
                love.graphics.newQuad(thing * self.frameW, row * self.frameH, self.frameW, self.frameH, w, h))
        end
    end

    return self
end

function Sprite:Update(delta)
    if not self.frames then return end
    print("updated")
    self.time = self.time + delta
    if self.time >= 1 / self.fps then
        print(self.frame)
        self.time = 0
        self.frame = self.frame + 1
        if self.frame > #self.animationQuads then
            self.frame = 1
        end
    end
end

function Sprite:Draw(ox, oy)
    if not self.visible then
        return
    end
	ox = ox or 0; oy = oy or 0

	local transform = self.entity:get("transform")
	local sx, sy = 1, 1
	if self.size > 0 then
		sx = self.size / self.frameW
		sy = self.size / self.frameH
	end

	local quad = self.quads and self.quads[directions[self.direction] or 2] or self.animationQuads and self.animationQuads[self.frame]
	local transform = self.entity:get("transform")
	local pos = transform.pos
	if quad then
		love.graphics.draw(self.image, quad, pos.x - ox - self.frameW * sx / 2, pos.y - oy - self.frameH * sy / 2, 0, sx, sy)
	else
		love.graphics.draw(self.image, pos.x - ox - self.frameW * sx / 2, pos.y - oy - self.frameH * sy / 2, 0, sx, sy)
	end
end

return Sprite
