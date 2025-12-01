local Entity = require("class.entity.entity")

---@class Matrix: Entity
---@field rows number
---@field cols number
---@field matrix any[][]
local Matrix = Entity:extend()
Matrix.super = Entity

function Matrix.fromTable(table)
	for i = 1, #table do
		assert(type(table[i]) == "table", "Each value of the given table must be a table.")
	end
	local rows = #table
	local cols = #table[1]
	---@type Matrix
	local m = Matrix(rows, cols, 0)
	m:forEach(function(x, y)
		local val = table[y][x]
		m:setCell(x, y, val)
	end)
	return m
end

---@param rows number
---@param cols number
---@param initVal any
function Matrix:new(rows, cols, initVal)
	Matrix.super.new(self, 0, 0)
	self.rows = rows
	self.cols = cols
	self.matrix = self:init(initVal)
end

function Matrix:init(initVal)
	initVal = initVal or 0
	local matrix = {}
	for my = 1, self.rows do
		matrix[my] = {}
		for mx = 1, self.cols do
			matrix[my][mx] = initVal
		end
	end
	return matrix
end

function Matrix:copy()
	---@type Matrix
	local m = Matrix(self.rows, self.cols, 0)
	m.x = self.x
	m.y = self.y
	self:forEach(function(x, y, v)
		m:setCell(x, y, v)
	end)
	return m
end

function Matrix:isValidCell(x, y)
	return x > 0 and x <= self.cols and y > 0 and y <= self.rows
end

function Matrix:getCell(x, y)
	if self:isValidCell(x, y) then
		return self.matrix[y][x]
	else
		return nil
	end
end

function Matrix:setCell(x, y, val)
	if x > 0 and x <= self.cols and y > 0 and y <= self.rows then
		self.matrix[y][x] = val
	else
		error(string.format("Cell %d,%d is out of matrix range", x, y))
	end
end

function Matrix:insertRow(pos, initVal)
	pos = pos or #self.matrix
	initVal = initVal or 0
	local row = {}
	for i = 1, self.cols do
		row[i] = 0
	end
	table.insert(self.matrix, pos, row)
	self.rows = self.rows + 1
	return row
end

function Matrix:removeRow(pos)
	table.remove(self.matrix, pos)
	self.rows = self.rows - 1
end

---@param func function
---@return any
function Matrix:forEach(func)
	local returnVal = nil
	for my = 1, #self.matrix do
		for mx = 1, #self.matrix[my] do
			local v = self.matrix[my][mx]
			returnVal = func(mx, my, v)
		end
	end
	return returnVal
end

---@param func function
---@return Matrix
function Matrix:map(func)
	local mapped = {}
	self:forEach(function(x, y, v)
		local result = func(x, y, v)
		table.insert(mapped, result)
	end)
	return mapped
end

---@alias rotation
---| "Clockwise"
---| "CounterClockwise"
---@param rot rotation
function Matrix:getRotation(rot)
	local matrix = self.matrix
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

---@param rot rotation
function Matrix:rotate(rot)
	local rotated = self:getRotation(rot)
	self.matrix = rotated

	local tmp = self.rows
	self.rows = self.cols
	self.cols = tmp
end

return Matrix
