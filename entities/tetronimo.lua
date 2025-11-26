local Entity = require("entities.entity")
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

---@class Tetronimo: Entity
---@field shape string
---@field matrix number[][]
---@field color table
local Tetronimo = Entity:extend()
Tetronimo.super = Entity

---@param shape string
function Tetronimo:new(shape)
	Tetronimo.super.new(self, 0, 0)
	self.shape = shape
	self.matrix = ShapeMatrices[shape]
	self.color = { 1, 1, 1, 1 }
end

function Tetronimo:draw()
	for i, row in ipairs(self.matrix) do
		for j, v in ipairs(row) do
			if v == 1 then
				local x = self.x + ((j - 1) * CELL_SIZE)
				local y = self.y + ((i - 1) * CELL_SIZE)
				love.graphics.setColor(self.color)
				love.graphics.rectangle("fill", x, y, CELL_SIZE, CELL_SIZE)
			end
		end
	end
end

function Tetronimo:getGridPosition()
	return self.x / CELL_SIZE + 1, self.y / CELL_SIZE + 1
end

function Tetronimo:setGridPosition(x, y)
	self:setPosition(x * CELL_SIZE, y * CELL_SIZE)
end

function Tetronimo:getMatrix()
	return self.matrix
end

function Tetronimo:setMatrix(matrix)
	self.matrix = matrix
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

---@alias rotation
---| "Clockwise"
---| "CounterClockwise"
---@param rot rotation
function Tetronimo:getRotation(rot)
	local matrix = self:getMatrix()
	local rotatedMatrix = {}

	-- Initialize rotated matrix
	for i = 1, #matrix[1] do
		rotatedMatrix[i] = {}
		for j = 1, #matrix do
			rotatedMatrix[i][j] = 0
		end
	end

	for my = 1, #matrix do
		for mx = 1, #matrix[my] do
			if rot == "Clockwise" then
				local y = mx
				local x = #matrix - (my - 1)
				rotatedMatrix[y][x] = matrix[my][mx]
			elseif rot == "CounterClockwise" then
				local y = #matrix[my] - (mx - 1)
				local x = my
				rotatedMatrix[y][x] = matrix[my][mx]
			end
		end
	end
	return rotatedMatrix
end

---@return Tetronimo
function Tetronimo.random()
	local keys = util.keys(ShapeMatrices)
	local i = love.math.random(1, #keys)
	return Tetronimo(keys[i])
end

return Tetronimo
