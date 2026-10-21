local point = require("core.point")
local xmlparser = require("core.xmlparser")
local files = require("core.files")
local logging = require("core.logging")
local etable = require("core.table")

---@class engine.render
---Global functions for render classes.
local render = {
	screenSize = point.point(love.graphics:getWidth(), love.graphics:getHeight()),
}

---@class engine.camera
render.camera = {
	position = point.point(),
}

--Imma make base geometry first and then get to sprite stuff

local Preloads = {
	Images = {},
	Sheets = {},
}
local Drawables = {}

---@class engine.color
---@field r number
---@field g number
---@field b number
---@field a number
local ColorClass = {}
ColorClass.__index = ColorClass

---Creates a color.
---@param r number?
---@param g number?
---@param b number?
---@param a number?
---@return engine.color
function render.color(r, g, b, a)
	local self = setmetatable({}, ColorClass)

	self.r = r or 0
	self.g = g or 0
	self.b = b or 0
	self.a = a or 1 -- alpha 1 by default. else transparent.

	return self
end

---@class engine.rectangle
---@field position engine.point
---@field size engine.point
---@field color engine.color
---@field layer number
---@field mode love.DrawMode
---@field resize engine.point
---@field body love.Body?
---@field shape love.Shape?
---@field fixture love.Fixture?
---@field anchor engine.point
---@field parallax number
local RectangleClass = {}
RectangleClass.__index = RectangleClass

---Creates a rectangle on the screen.
---@param position engine.point?
---@param size engine.point?
---@param color engine.color?
---@param layer number?
---@param mode love.DrawMode?
---@param parallax number?
---@return engine.rectangle
function render.rectangle(position, size, mode, color, layer, parallax)
	---@class engine.rectangle
	local self = setmetatable({}, RectangleClass)

	self.position = position or point.point()
	self.size = size or point.point()
	self.color = color or render.color()
	self.layer = layer or 1
	self.mode = mode or "fill"
	self.resize = point.point(1, 1)
	self.anchor = point.point(0.5, 0.5)
	self.parallax = parallax or 1
	self.rotation = 0

	Drawables[#Drawables + 1] = self

	return self
end

function RectangleClass:Destroy()
	Drawables[etable.find(Drawables, self)] = nil
	etable.deepClear(self)
end

function RectangleClass:Draw(offset)
	if not offset then
		offset = point.point()
	end
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.rectangle(
		self.mode,
		offset.x + self.position.x - self.size.x * self.anchor.x,
		offset.y + self.position.y - self.size.y * self.anchor.y,
		self.size.x,
		self.size.y,
		self.resize.x,
		self.resize.y
	)
	love.graphics.setColor(1, 1, 1, 1)
end

---@class engine.text
local TextClass = {}
TextClass.__index = TextClass

render.defaultFont = love.graphics.newFont()

---Create a text object.
---@param text string
---@param position any
---@param layer any
---@param parallax any
---@param font any
---@param color any
---@param anchor any
---@return engine.text
function render.text(text, position, layer, parallax, font, color, anchor)
	---@class engine.text
	local self = setmetatable({}, TextClass)

	self.text = text or ""
	self.font = font or render.defaultFont
	self.position = position or point.point()
	self.anchor = anchor or point.point(0.5, 0.5)
	self.color = color or point.point()
	self.layer = layer or 1
	self.parallax = parallax or 1
	self.rotation = 0

	local lines = 1
	-- Count the number of newline characters
	for _ in self.text:gmatch("\n") do
		lines = lines + 1
	end

	self.size = point.point(self.font:getWidth(self.text), self.font:getHeight() * lines)

	Drawables[#Drawables + 1] = self

	return self
end

function TextClass:Destroy()
	Drawables[etable.find(Drawables, self)] = nil
	etable.deepClear(self)
end

function TextClass:Draw(offset)
	if not offset then
		offset = point.point()
	end
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.print(
		self.text,
		self.font,
		offset.x + self.position.x - self.size.x * self.anchor.x,
		offset.y + self.position.y - self.size.y * self.anchor.y
	)
	love.graphics.setColor(1, 1, 1, 1)
end

---@class engine.image
---@field position engine.point
---@field size engine.point
---@field layer number
---@field resize engine.point
---@field body love.Body?
---@field shape love.Shape?
---@field fixture love.Fixture?
---@field anchor engine.point
---@field parallax number
local ImageClass = {}
ImageClass.__index = ImageClass

function render.image(path, position, layer, resize, anchor, parallax)
	---@class engine.image
	local self = setmetatable({}, ImageClass)

	self.image = Preloads.Images[path] or love.graphics.newImage(path)
	self.position = position or point.point()
	self.resize = resize or point.point(1, 1)
	self.anchor = anchor or point.point(0.5, 0.5)
	self.layer = layer or 1
	self.parallax = parallax or 1
	self.rotation = 0

	self.size = point.point(self.image:getWidth() * self.resize.x, self.image:getHeight() * self.resize.y)

	Drawables[#Drawables + 1] = self

	return self
end

function ImageClass:Destroy()
	Drawables[etable.find(Drawables, self)] = nil
	etable.deepClear(self)
end

function ImageClass:Draw(offset)
	if not offset then
		offset = point.point()
	end
	love.graphics.draw(
		self.image,
		offset.x + self.position.x - self.size.x * self.anchor.x,
		offset.y + self.position.y - self.size.y * self.anchor.y,
		self.rotation or 0,
		self.resize.x,
		self.resize.y
	)
end

---@class engine.sprite
---@field position engine.point
---@field size engine.point
---@field layer number
---@field resize engine.point
---@field body love.Body?
---@field shape love.Shape?
---@field fixture love.Fixture?
---@field anchor engine.point
---@field parallax number
local SpriteClass = {}
SpriteClass.__index = SpriteClass

function render.sprite(path, position, layer, resize, anchor, parallax, sheetPath)
	---@class engine.sprite
	local self = setmetatable({}, SpriteClass)
	local imagePath
	if not sheetPath then
		imagePath = path .. ".png"
		sheetPath = path .. ".xml"
	end

	self.image = Preloads.Images[imagePath] or love.graphics.newImage(imagePath)

	self.position = position or point.point()
	self.resize = resize or point.point(1, 1)
	self.anchor = anchor or point.point(0.5, 0.5)
	self.layer = layer or 1
	self.parallax = parallax or 1
	self.frame = 0
	self.rotation = 0

	self.size = point.point(self.image:getWidth() * self.resize.x, self.image:getHeight() * self.resize.y)

	local sheet = files.read(sheetPath)
	assert(sheet, "Sheet " .. sheet .. " failed to load.")
	local parsed = xmlparser:ParseXmlText(sheet).TextureAtlas.SubTexture
	self.animations = {}
	for _, frame in next, parsed do
		local x = frame["@x"]
		local y = frame["@y"]
		local width = frame["@width"]
		local height = frame["@height"]
		local frameX = frame["@frameX"]
		local frameY = frame["@frameY"]
		local _frameW = frame["@frameWidth"]
		local _frameH = frame["@frameHeight"]
		local name = frame["@name"]
		local _rotated = frame["@rotated"]

		local num = tonumber(string.sub(name, name:len() - 3, name:len()))

		if not self.animations[name:sub(0, name:len() - 4)] then
			self.animations[name:sub(0, name:len() - 4)] = {}
		end

		self.animations[name:sub(0, name:len() - 4)][num] = {
			offset = point.point(frameX or 0, frameY or 0),
			resize = point.point(1, 1),
			quad = love.graphics.newQuad(x, y, width, height, self.image),
			rotated = false,
		}
	end

	Drawables[#Drawables + 1] = self

	return self
end

function SpriteClass:Destroy()
	Drawables[etable.find(Drawables, self)] = nil
	etable.deepClear(self)
end

function SpriteClass:Play(anim, fps, loop)
	assert(self.animations[anim], "Could not find animation " .. anim .. " in Sprite[" .. (self.id or "noId") .. "]")

	self.animation = anim
	self.frame = 0
	self.loop = loop
	self.lastFrame = 0
	self.fps = fps
end

function SpriteClass:Draw(offset)
	-- print(self.animation, self.frame, self.animations[self.animation][self.frame].quad)
	if not self.animation then
		return
	end
	if not offset then
		offset = point.point()
	end
	local _, _, quadSizeX, quadSizeY = self.animations[self.animation][0].quad:getViewport()
	local quadObj = self.animations[self.animation][self.frame]
	love.graphics.draw(
		self.image,
		quadObj.quad,
		offset.x
			+ self.position.x
			- quadSizeX * self.anchor.x * self.resize.x
			- quadObj.offset.x * self.resize.x
			+ (self.flipX and quadSizeX or 0), -- - math.cos(self.rotation) * quadSizeX * self.resize.x * self.anchor.x,
		offset.y + self.position.y - quadSizeY * self.anchor.y * self.resize.y - quadObj.offset.y * self.resize.y, -- - math.sin(self.rotation) * quadSizeY * self.resize.y * self.anchor.y,
		self.rotation or 0,
		self.resize.x,
		self.resize.y
	)
end

function SpriteClass:Update(delta)
	if not self.animation then
		return
	end

	self.lastFrame = self.lastFrame + delta
	if self.lastFrame >= 1 / self.fps then
		local frameSkip = math.floor((1 / self.fps) / self.lastFrame)
		self.lastFrame = self.lastFrame - (1 / self.fps) * (frameSkip + 1)
		if not self.animations[self.animation][self.frame + (frameSkip + 1)] and self.loop then
			self.frame = frameSkip
		elseif self.animations[self.animation][self.frame + (frameSkip + 1)] then
			self.frame = self.frame + frameSkip + 1
		end
	end
end

---Resize all the sprite quads and offsets.
---@param resize engine.point
function SpriteClass:Resize(resize)
	for _, animation in next, self.animations do
		for _, quadobject in next, animation do
			print(logging.dump(quadobject))
			quadobject.resize = quadobject.resize:Mul(resize)
			quadobject.offset = quadobject.offset:Mul(resize)
		end
	end
end

function render.draw()
	table.sort(Drawables, function(a, b)
		if a.layer < b.layer then
			return true
		else
			return false
		end
	end)
	local screenSize = point.point(love.graphics.getWidth(), love.graphics.getHeight())

	for _, drawable in next, Drawables do
		if drawable.body then
			-- if drawable.body:getType() == "dynamic" then
			drawable.position.x = drawable.body:getX()
			drawable.position.y = drawable.body:getY()
			drawable.rotation = drawable.body:getAngle()
			-- else
			--     drawable.body:setX(drawable.position.x)
			--     drawable.body:setY(drawable.position.y)
			--     drawable.body:setAngle(drawable.rotation)
			-- end

			if render.physdebug then
				if drawable.shape:getType() == "polygon" then
					love.graphics.setColor(0.20, 0.20, 0.20) -- set the drawing color to grey for the blocks
					love.graphics.polygon("fill", drawable.body:getWorldPoints(drawable.shape:getPoints()))
					love.graphics.setColor(1, 1, 1) -- set the drawing color to grey for the blocks
				end
			end
		end
		local offset = point.point(
			screenSize.x / 2 - render.camera.position.x * (drawable.parallax or 1),
			screenSize.y / 2 - render.camera.position.y * (drawable.parallax or 1)
		)

		drawable:Draw(offset)
	end
end

function render.update(delta)
	render.screenSize = point.point(love.graphics:getWidth(), love.graphics:getHeight())

	for _, drawable in next, Drawables do
		if drawable.Update then
			drawable:Update(delta)
		end
	end
end

---[[
---Leaving this for table.findofclass and other stuff like this that needs you to verify the class
---]]

return render
