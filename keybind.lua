local CONST = {
	DEFAULT_DELAY = 0.25,
	DEFAULT_FREQ = 30,
}

---@class Keybind: Object
---@field key love.KeyConstant
---@field func function
---@field doesRepeat boolean
---@field perSecond number
---@field repeatDelay number
local Keybind = Object:extend()

---@param key love.KeyConstant
---@param func function
---@param delay? boolean | number
---@param perSecond? number
function Keybind:new(key, func, delay, perSecond)
	self.key = key
	self.func = func or function() end
	self.perSecond = perSecond or CONST.DEFAULT_FREQ

	if type(delay) == "nil" then
		delay = false
	end

	if type(delay) == "boolean" then
		self.doesRepeat = delay
		self.repeatDelay = CONST.DEFAULT_DELAY
	elseif type(delay) == "number" then
		self.doesRepeat = true
		self.repeatDelay = delay
	end

	self._timeHeld = 0
	self._repeatTimer = 0
	self._wasDown = false
end

function Keybind:update(dt)
	if love.keyboard.isDown(self.key) then
		if self._wasDown and not self.doesRepeat then
			return
		end

		self._timeHeld = self._timeHeld + dt
		if not self._wasDown then
			self.func()
		elseif self._timeHeld > self.repeatDelay then
			if self._repeatTimer <= 0 then
				self.func()
				self._repeatTimer = self._repeatTimer + 1
			end
			self._repeatTimer = self._repeatTimer - self.perSecond * dt
		end

		self._wasDown = true
	else
		self._timeHeld = 0
		self._repeatTimer = 0
		self._wasDown = false
	end
end

return Keybind
