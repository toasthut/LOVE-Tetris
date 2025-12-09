---@class Stopwatch: Object
---@field protected time number
---@field running boolean
local Stopwatch = Object:extend()

function Stopwatch:new()
	self.time = 0.0
	self.running = false
end

function Stopwatch:update(dt)
	if self.running then
		self.time = self.time + dt
	end
end

function Stopwatch:start()
	self.running = true
end

function Stopwatch:pause()
	self.running = false
end

function Stopwatch:reset()
	self.time = 0.0
end

function Stopwatch:stop()
	self:pause()
	self:reset()
end

function Stopwatch:getTime()
	return self.time
end

function Stopwatch:isRunning()
	return self.running
end

return Stopwatch
