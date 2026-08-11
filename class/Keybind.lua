local CONST = {
	DEFAULT_DELAY = 0.19,
	DEFAULT_FREQ = 30,
}

---@class Keybind: Object
---@field key love.KeyConstant
---@field func function
---@field doesRepeat boolean
---@field perSecond number
---@field repeatDelay number
---@field interrupts love.KeyConstant[]
local Keybind = Object:extend()

---@param key love.KeyConstant
---@param func function
---@param delay? boolean | number
---@param perSecond? number
---@param interrupts? love.KeyConstant[]
function Keybind:new(key, func, delay, perSecond, interrupts)
	self.key = key
	self.func = func or function() end
	self.perSecond = perSecond or CONST.DEFAULT_FREQ
	self.interrupts = interrupts or {}

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

	for i = 1, #self.interrupts do
		local v = self.interrupts[i]
		assert(v ~= self.key, "Interrupt cannot be the same key as the keybind.")
	end

	self._timeHeld = 0
	self._repeatTimer = 0
	self._wasDown = false
	return self
end

function Keybind:update(dt)
	local doKeyFunction = love.keyboard.isDown(self.key)

	if doKeyFunction and #self.interrupts > 0 then
		for i = 1, #self.interrupts do
			if love.keyboard.isDown(self.interrupts[i]) then
				doKeyFunction = false
				break
			end
		end
	end

	if doKeyFunction then
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
