local Matrix = require("entities.matrix")
local CELL_SIZE = require("constants").CELL_SIZE

---@enum ShapeMatrices
local ShapeMatrices = {
	I = {
		{ 1, 1, 1, 1 },
	},
	O = {
		{ 1, 1 },
		{ 1, 1 },
	},
	S = {
		{ 0, 1, 1 },
		{ 1, 1, 0 },
	},
	Z = {
		{ 1, 1, 0 },
		{ 0, 1, 1 },
	},
	L = {
		{ 0, 0, 1 },
		{ 1, 1, 1 },
	},
	J = {
		{ 1, 0, 0 },
		{ 1, 1, 1 },
	},
	T = {
		{ 0, 1, 0 },
		{ 1, 1, 1 },
		{ 0, 0, 0 },
	},
}

---@class Tetronimo: Matrix
---@field shape string
---@field color table
local Tetronimo = Matrix:extend()
Tetronimo.super = Matrix

---@param shape string
function Tetronimo:new(shape)
	local matrix = Matrix.fromTable(ShapeMatrices[shape])
	Tetronimo.super.new(self, matrix.rows, matrix.cols, 0)
	self.matrix = matrix.matrix
	self.shape = shape
	self.color = { 1, 1, 1, 1 }
end

function Tetronimo:draw()
	self:forEach(function(mx, my, v)
		if v == 1 then
			local x = self.x + ((mx - 1) * CELL_SIZE)
			local y = self.y + ((my - 1) * CELL_SIZE)
			love.graphics.setColor(self.color)
			love.graphics.rectangle("fill", x, y, CELL_SIZE, CELL_SIZE)
		end
	end)
end

function Tetronimo:getGridPosition()
	return self.x / CELL_SIZE + 1, self.y / CELL_SIZE + 1
end

function Tetronimo:setGridPosition(x, y)
	self:setPosition(x * CELL_SIZE, y * CELL_SIZE)
end

---@alias direction
---| "Left"
---| "Right"
---| "Down"
---@param dir direction
---@param num? number
function Tetronimo:move(dir, num)
	num = num or 1
	switch(dir)({
		["Left"] = function()
			self.x = self.x - CELL_SIZE * num
		end,
		["Right"] = function()
			self.x = self.x + CELL_SIZE * num
		end,
		["Down"] = function()
			self.y = self.y + CELL_SIZE * num
		end,
	})
end

---@return Tetronimo
function Tetronimo.random()
	local keys = util.keys(ShapeMatrices)
	local i = love.math.random(1, #keys)
	return Tetronimo(keys[i])
end

return Tetronimo
