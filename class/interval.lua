local Timer = require("class.timer")

---@class Interval: Timer
---@field length number
---@field event function
local Interval = Timer:extend()
Interval.super = Timer
Interval.MAX_EVENTS = 1000

function Interval:new(length, event)
	Interval.super.new(self)
	self.running = true
	self.length = length
	self.event = event
end

function Interval:update(dt)
	self.super.update(self, dt)
	if self.time >= self.length then
		local nEvents = math.floor(self.time / self.length)
		for _ = 1, math.min(nEvents, self.MAX_EVENTS) do
			self.event()
		end
		self.time = self.time - (self.length * nEvents)
	end
end

function Interval:forceTrigger()
	self.event()
	self:reset()
end

function Interval:setLength(length)
	self.length = length
end

return Interval
