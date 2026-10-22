local Sprite = {}
Sprite.__index = Sprite

local directions = { south = 1, north = 2, east = 3, west = 4 }

function Sprite.new(entity, data)
	local self = setmetatable({}, Sprite)
	self.entity = entity

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
	end

	return self
end

function Sprite:Draw(ox, oy)
	ox = ox or 0; oy = oy or 0

	local transform = self.entity:get("transform")
	local sx, sy = 1, 1
	if self.size > 0 then
		sx = self.size / self.frameW
		sy = self.size / self.frameH
	end

	local quad = self.quads and self.quads[directions[self.direction] or 2]
	if quad then
		love.graphics.draw(self.image, quad, transform.x - ox - self.frameW * sx / 2, transform.y - oy - self.frameH * sy / 2, 0, sx, sy)
	else
		love.graphics.draw(self.image, transform.x - ox - self.frameW * sx / 2, transform.y - oy - self.frameH * sy / 2, 0, sx, sy)
	end
end

return Sprite
