local Matrix = require("class.entity.matrix")
local CellState = require("constants").CellState
local CELL_SIZE = require("constants").CELL_SIZE

---@enum TetShapes
local TetShapes = {
	I = {
		shape = {
			{ 1, 1, 1, 1 },
		},
		color = util.hexToRGB("00ffff"),
	},
	O = {
		shape = {
			{ 1, 1 },
			{ 1, 1 },
		},
		color = util.hexToRGB("ffff00"),
	},
	S = {
		shape = {
			{ 0, 1, 1 },
			{ 1, 1, 0 },
		},
		color = util.hexToRGB("00ff00"),
	},
	Z = {
		shape = {
			{ 1, 1, 0 },
			{ 0, 1, 1 },
		},
		color = util.hexToRGB("ff0000"),
	},
	L = {
		shape = {
			{ 0, 0, 1 },
			{ 1, 1, 1 },
		},
		color = util.hexToRGB("ffaa00"),
	},
	J = {
		shape = {
			{ 1, 0, 0 },
			{ 1, 1, 1 },
		},
		color = util.hexToRGB("0000ff"),
	},
	T = {
		shape = {
			{ 0, 1, 0 },
			{ 1, 1, 1 },
			{ 0, 0, 0 },
		},
		color = util.hexToRGB("9900ff"),
	},
}

---@class Tetronimo: Matrix
---@field shape string
---@field color table
local Tetronimo = Matrix:extend()
Tetronimo.super = Matrix

---@param shape string
function Tetronimo:new(shape)
	local prefab = TetShapes[shape]
	local matrix = Matrix.fromTable(prefab.shape)
	Tetronimo.super.new(self, matrix.rows, matrix.cols, 0)
	self.matrix = matrix.matrix
	self.shape = shape
	self.color = prefab.color
end

function Tetronimo:copy()
	---@type Tetronimo
	local t = Tetronimo("T")
	---@type Matrix
	local matrix = self.super.copy(self)

	t.x = matrix.x
	t.y = matrix.y
	t.rows = matrix.rows
	t.cols = matrix.cols
	t.matrix = matrix.matrix
	t.shape = self.shape

	return t
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

---@return number, number
function Tetronimo:getGridPosition()
	return self.x / CELL_SIZE + 1, self.y / CELL_SIZE + 1
end

function Tetronimo:setGridPosition(x, y)
	x = x - 1
	y = y - 1
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

function Tetronimo:getFullCells()
	local tx, ty = self:getGridPosition()

	local cells = self:map(function(mx, my, v)
		if v == CellState.FULL then
			local x = tx + mx - 1
			local y = ty + my - 1
			return { x = x, y = y }
		end
	end)

	return cells
end

---@return Tetronimo
function Tetronimo.random()
	local keys = util.keys(TetShapes)
	local i = love.math.random(1, #keys)
	return Tetronimo(keys[i])
end

return Tetronimo
