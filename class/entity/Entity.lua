---@class Entity: Object
---@field x number
---@field y number
local Entity = Object:extend()

---@param x number
---@param y number
function Entity:new(x, y)
	self.x = x
	self.y = y
end

function Entity:copy()
	---@type Entity
	local e = Entity(self.x, self.y)
	return e
end

---@param dt number
---@diagnostic disable-next-line: unused-local
function Entity:update(dt) end
function Entity:draw() end

---@param x number
function Entity:setX(x)
	self.x = x
end

---@param y number
function Entity:setY(y)
	self.y = y
end

---@param x number
---@param y number
function Entity:setPosition(x, y)
	self:setX(x)
	self:setY(y)
end

return Entity
