local Entity = require("entities.entity")

---@class Rectangle: Entity
local Rectangle = Entity:extend()

---@param width number
---@param height number
function Rectangle:new(x, y, width, height)
	---@diagnostic disable-next-line: undefined-field
	Entity.super.new(self, x, y)
	self.width = width
	self.height = height
end

return Rectangle
