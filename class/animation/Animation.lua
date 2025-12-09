local IntervalCallback = require("class.timer.IntervalCallback")
local TimedCallback = require("class.timer.TimedCallback")

---@class Animation: Object
---@field interval IntervalCallback
---@field timer TimedCallback
local Animation = Object:extend()

---@param frames number
---@param frameLength number
function Animation:new(frames, frameLength)
	local length = frames * frameLength
	self.interval = IntervalCallback(frameLength, function()
		self:processFrame()
	end, false)
	self.timer = TimedCallback(length, function()
		self.interval:stop()
	end, false)
end

function Animation:update(dt)
	self.interval:update(dt)
	self.timer:update(dt)
end

function Animation:play()
	self.timer:reset()
	self.timer:start()
	self.interval:forceTrigger()
	self.interval:start()
end

function Animation:draw()
	error("Implement draw in subclass.")
end

function Animation:processFrame()
	error("Implement processFrame in subclass.")
end

return Animation
