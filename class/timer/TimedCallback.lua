local Stopwatch = require("class.timer.Stopwatch")

---@class TimedCallback: Stopwatch
---@field protected length number
---@field protected callback function
local TimedCallback = Stopwatch:extend()
TimedCallback.super = Stopwatch

---@param length number
---@param callback? function
---@param start? boolean
function TimedCallback:new(length, callback, start)
	TimedCallback.super.new(self)
	self.callback = callback or function() end
	self.length = length

	if start == nil or start then
		self:start()
	end
end

function TimedCallback:update(dt)
	self.super.update(self, dt)

	if self.time >= self.length then
		self:stop()
		self.callback()
	end
end

function TimedCallback:forceTrigger()
	self.callback()
	self:stop()
end

function TimedCallback:getLength()
	return self.length
end

function TimedCallback:setLength(length)
	self.length = length
end

return TimedCallback
