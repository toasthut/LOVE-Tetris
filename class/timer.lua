---@class Timer: Object
---@field time number
---@field running boolean
local Timer = Object:extend()

function Timer:new()
	self.time = 0.0
	self.running = false
end

function Timer:update(dt)
	if self.running then
		self.time = self.time + dt
	end
end

function Timer:start()
	self.running = true
end

function Timer:stop()
	self.running = false
end

function Timer:reset()
	self.time = 0.0
end

return Timer
