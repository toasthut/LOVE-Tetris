local Entity = require("class.entity.entity")
local PALETTE = require("constants").PALETTE

---@class Button: Entity
local Button = Entity:extend()
Button.super = Entity

---@param x number
---@param y number
---@param w number
---@param h number
---@param rx number
---@param label string
---@param fn function
---@param colors table<string,table>
function Button:new(x, y, w, h, rx, label, fn, colors)
	Button.super.new(self, x, y)
	self.width = w
	self.height = h
	self.rx = rx
	self.drawMode = "fill"
	self.label = label
	self.fn = fn
	self.hot = false
	self.enabled = true

	self.palette = {
		idle = PALETTE.cloud,
		hovered = PALETTE.peach,
		clicked = PALETTE.melon,
		text = PALETTE.night,
		disabled = PALETTE.dusk,
	}
	if colors then
		for k, v in pairs(colors) do
			self.palette[k] = v
		end
	end
	self.btnColor = self.palette.idle
	self.textColor = self.palette.text

	self.mx, self.my = 0, 0
end

---@diagnostic disable-next-line: unused-local
function Button:update(dt)
	if not self.enabled then
		self.btnColor = self.palette.disabled
		return
	else
		self.btnColor = self.palette.idle
	end

	local mx, my = self.mx, self.my
	self.hot = mx > self.x and mx < self.x + self.width and my > self.y and my < self.y + self.height
	self.last = self.now
	self.now = love.mouse.isDown(1)

	if self.now and self.hot then -- Clicked
		self.btnColor = self.palette.clicked
	elseif self.hot then -- Hovered
		self.btnColor = self.palette.hovered
	else -- Idle
		self.btnColor = self.palette.idle
	end

	if not self.now and self.last and self.hot then
		self.fn()
	end
end

function Button:draw()
	love.graphics.push()
	love.graphics.setColor(self.btnColor)
	love.graphics.rectangle(self.drawMode, self.x, self.y, self.width, self.height, self.rx)

	love.graphics.setFont(Fonts.button)
	love.graphics.setColor(self.textColor)
	local font = love.graphics.getFont()
	local vertOffset = (self.height - font:getHeight()) / 2
	love.graphics.printf(self.label, self.x, self.y + vertOffset, self.width, "center")
	love.graphics.setFont(Fonts.default)

	self.mx, self.my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	love.graphics.pop()
end

function Button:toggle()
	self.enabled = not self.enabled
end

return Button
