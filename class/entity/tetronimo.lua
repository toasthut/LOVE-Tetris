local Matrix = require("class.entity.matrix")
local Cell = require("class.cell")
local PALETTE = require("constants").PALETTE

---@enum TetShapes
local TetShapes = {
	I = {
		shape = {
			{ 1, 1, 1, 1 },
		},
		color = PALETTE.aqua,
	},
	O = {
		shape = {
			{ 1, 1 },
			{ 1, 1 },
		},
		color = PALETTE.lemon,
	},
	S = {
		shape = {
			{ 0, 1, 1 },
			{ 1, 1, 0 },
		},
		color = PALETTE.lime,
	},
	Z = {
		shape = {
			{ 1, 1, 0 },
			{ 0, 1, 1 },
		},
		color = PALETTE.strawberry,
	},
	L = {
		shape = {
			{ 0, 0, 1 },
			{ 1, 1, 1 },
		},
		color = PALETTE.carrot,
	},
	J = {
		shape = {
			{ 1, 0, 0 },
			{ 1, 1, 1 },
		},
		color = PALETTE.skyblue,
	},
	T = {
		shape = {
			{ 0, 1, 0 },
			{ 1, 1, 1 },
			{ 0, 0, 0 },
		},
		color = PALETTE.swell,
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
	local t = Tetronimo(self.shape)
	---@type Matrix
	local matrix = self.super.copy(self)

	t.x = matrix.x
	t.y = matrix.y
	t.rows = matrix.rows
	t.cols = matrix.cols
	t.matrix = matrix.matrix

	t.color = {}
	for i = 1, #self.color do
		t.color[i] = self.color[i]
	end

	return t
end

function Tetronimo:draw()
	self:forEach(function(mx, my, v)
		if v == 1 then
			local x = self.x + ((mx - 1) * Cell.SIZE)
			local y = self.y + ((my - 1) * Cell.SIZE)
			Cell:draw(x, y, self.color)
		end
	end)
end

---@return number, number
function Tetronimo:getGridPosition()
	return self.x / Cell.SIZE + 1, self.y / Cell.SIZE + 1
end

function Tetronimo:setGridPosition(x, y)
	x = x - 1
	y = y - 1
	self:setPosition(x * Cell.SIZE, y * Cell.SIZE)
end

---@alias direction
---| "Left"
---| "Right"
---| "Down"
---@param dir direction
---@param num? number
function Tetronimo:move(dir, num)
	num = num or 1
	if dir == "Left" then
		self.x = self.x - Cell.SIZE * num
	elseif dir == "Right" then
		self.x = self.x + Cell.SIZE * num
	elseif dir == "Down" then
		self.y = self.y + Cell.SIZE * num
	end
end

function Tetronimo:getFullCells()
	local tx, ty = self:getGridPosition()

	local cells = self:map(function(mx, my, v)
		if v == Cell.STATE.FULL then
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

return {
	Tetronimo = Tetronimo,
	TetShapes = TetShapes,
}
