local Animation = require("class.animation.Animation")

---@class Shaker: Animation
---@field magnitude number
local Shaker = Animation:extend()
Shaker.super = Animation

---@param magnitude number
function Shaker:new(frames, frameLength, magnitude)
	Shaker.super.new(self, frames, frameLength)
	self.offset = { x = 0, y = 0 }
	self.magnitude = magnitude
end

function Shaker:draw()
	love.graphics.translate(self.offset.x, self.offset.y)
end

function Shaker:processFrame()
	local length = self.timer:getLength()
	local delta = (length - self.timer:getTime()) / length
	self.offset.x = love.math.random(-self.magnitude, self.magnitude) * delta
	self.offset.y = love.math.random(-self.magnitude, self.magnitude) * delta * 0.1
end

return Shaker
