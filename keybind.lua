local DEFAULT_DELAY = require("constants").DEFAULT_DELAY

---@class Keybind: Object
local Keybind = Object:extend()

---@param key love.KeyConstant
---@param func function
---@param delay? boolean | number
---@param repeatFreq? number
function Keybind:new(key, func, delay, repeatFreq)
	self.key = key
	self.func = func or function() end
	self.repeatFreq = repeatFreq or 0.045

	if type(delay) == "nil" then
		delay = true
	end

	if type(delay) == "boolean" then
		self.doesRepeat = delay
		self.repeatDelay = DEFAULT_DELAY
	elseif type(delay) == "number" then
		self.doesRepeat = true
		self.repeatDelay = delay
	end

	self.repeatTimer = 0
	self.timeHeld = 0
	self.wasDown = false
	self.isRepeating = false
end

function Keybind:update(dt)
	if love.keyboard.isDown(self.key) then
		if self.wasDown and not self.doesRepeat then
			return
		end

		self.timeHeld = self.timeHeld + dt
		if not self.wasDown then
			self.func()
		elseif self.doesRepeat and self.timeHeld > self.repeatDelay and not self.isRepeating then
			self.isRepeating = true
			self.func()
		end

		if self.isRepeating then
			local t = self.timeHeld - self.repeatDelay
			if t > self.repeatFreq then
				self.func()
				self.timeHeld = self.timeHeld - self.repeatFreq
			end
		end

		self.wasDown = true
	else
		self.timeHeld = 0
		self.wasDown = false
		self.isRepeating = false
	end
end

return Keybind
