local TimedCallback = require("class.timer.TimedCallback")

---@class IntervalCallback: TimedCallback
local IntervalCallback = TimedCallback:extend()
IntervalCallback.super = TimedCallback
IntervalCallback.MAX_LOOPS = 1000

---@param length number
---@param callback function
---@param start? boolean
function IntervalCallback:new(length, callback, start)
	IntervalCallback.super.new(self, length, callback, start)
end

function IntervalCallback:update(dt)
	if not self.running then
		return
	end

	self.time = self.time + dt

	local loops = 1
	while self.time >= self.length and loops < self.MAX_LOOPS do
		self.callback()
		self.time = self.time - self.length
		loops = loops + 1
	end
	assert(loops < self.MAX_LOOPS, "Infinite loop prevented in IntervalCallback.")
end

function IntervalCallback:forceTrigger()
	self.callback()
	self.time = self.length
end

return IntervalCallback
