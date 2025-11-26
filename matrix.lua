---@class Matrix: Object
local Matrix = Object:extend()

function Matrix.fromTable(table)
	for i = 1, #table do
		assert(type(table[i]) == "table", "Each value of the given table must be a table.")
	end
	local rows = #table
	local cols = #table[1]
	---@type Matrix
	local matrix = Matrix(rows, cols, 0)
	matrix:forEach(function(x, y)
		local val = table[y][x]
		matrix:setCell(x, y, val)
	end)
	return matrix
end

function Matrix:new(rows, cols, initVal)
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

function Matrix:getCell(x, y)
	return self.matrix[y][x]
end

function Matrix:setCell(x, y, val)
	self.matrix[y][x] = val
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

function Matrix:setMatrix(matrix)
	self.matrix = matrix
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
end

return Matrix
