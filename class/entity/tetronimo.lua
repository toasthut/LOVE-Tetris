local Matrix = require("class.entity.matrix")
local Cell = require("class.cell")
local PALETTE = require("constants").PALETTE

---@enum TetShapes
local TetShapes = {
	I = {
		shape = {
			{ 0, 0, 0, 0 },
			{ 1, 1, 1, 1 },
			{ 0, 0, 0, 0 },
			{ 0, 0, 0, 0 },
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
			{ 0, 0, 0 },
		},
		color = PALETTE.lime,
	},
	Z = {
		shape = {
			{ 1, 1, 0 },
			{ 0, 1, 1 },
			{ 0, 0, 0 },
		},
		color = PALETTE.strawberry,
	},
	L = {
		shape = {
			{ 0, 0, 1 },
			{ 1, 1, 1 },
			{ 0, 0, 0 },
		},
		color = PALETTE.carrot,
	},
	J = {
		shape = {
			{ 1, 0, 0 },
			{ 1, 1, 1 },
			{ 0, 0, 0 },
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
---@field degreesRotated deg90Interval
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
	self.degreesRotated = 0
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

	t.degreesRotated = self.degreesRotated
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

---@param x number
---@param y number
function Tetronimo:move(x, y)
	self.x = self.x + Cell.SIZE * x
	self.y = self.y + Cell.SIZE * y
end

function Tetronimo:rotate(rot)
	self.super.rotate(self, rot)
	if rot == "Clockwise" then
		self.degreesRotated = (self.degreesRotated + 90) % 360
	elseif rot == "CounterClockwise" then
		self.degreesRotated = (self.degreesRotated - 90) % 360
	end
end

function Tetronimo:getCellGridPositions()
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

function Tetronimo.generateKicks()
	local rotDirections = { "Clockwise", "CounterClockwise" }
	local rotDegrees = { 0, 90, 180, 270 }
	local kicks = {}
	for _, a in ipairs(rotDirections) do
		kicks[a] = {}
		for _, b in ipairs(rotDegrees) do
			local k = Tetronimo.getKicks(a, b)
			kicks[a][tostring(b)] = k
		end
	end
	return kicks
end

---@private
---@param rot rotation
---@param targetDeg deg90Interval
---@return table[]
function Tetronimo.getKicks(rot, targetDeg)
	local kicks = {}
	-- The default y values in this data have been inverted because in this program,
	-- a positive y value represents downward movement
	local kickDefaults = {
		{ 0, 0 },
		{ -1, 0 },
		{ -1, -1 },
		{ 0, 2 },
		{ -1, 2 },
	}

	for i, v in ipairs(kickDefaults) do
		local x, y = v[1], v[2]
		if x ~= 0 then
			if rot == "Clockwise" and math.floor(targetDeg / 180) == 1 then
				x = x * -1
			end
			if rot == "CounterClockwise" and math.ceil(targetDeg / 180) ~= 1 then
				x = x * -1
			end
		end

		if y ~= 0 then
			if targetDeg % 180 == 0 then
				y = y * -1
			end
		end

		table.insert(kicks, i, { x, y })
	end
	return kicks
end

Tetronimo.KICKS = Tetronimo.generateKicks()
print(util.tableToString(Tetronimo.KICKS, "Kicks"))

return {
	Tetronimo = Tetronimo,
	TetShapes = TetShapes,
}
