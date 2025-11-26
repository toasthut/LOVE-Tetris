local Entity = require("entities.entity")
local Tetronimo = require("entities.tetronimo")
local CELL_SIZE = require("constants").CELL_SIZE

---@enum State
local State = {
	EMPTY = 0,
	FULL = 1,
}

---@class Board: Entity
---@field cols number
---@field rows number
---@field gridMatrix number[][]
---@field activePiece Tetronimo
---@field fallDelay number
---@field fallTimer number
local Board = Entity:extend()
Board.super = Entity

---@return Board
function Board:new()
	Board.super.new(self, 0, 0)
	self.cols = 10
	self.rows = 20

	self.gridMatrix = self:initGrid()

	self:spawnPiece(Tetronimo("T"))
	self.fallDelay = 6
	self.fallTimer = 0
	return self
end

---@param func function
function Board:forMatrix(func)
	for my = 1, self.rows do
		for mx = 1, self.cols do
			func(my, mx)
		end
	end
end

function Board:initGrid()
	local matrix = {}
	self:forMatrix(function(my, mx)
		if not matrix[my] then
			matrix[my] = {}
		end
		matrix[my][mx] = 0
	end)
	Log:print("grid height: " .. #matrix)
	Log:print("grid width: " .. #matrix[1])
	return matrix
end

function Board:initRow()
	local row = {}
	for i = 1, self.cols do
		row[i] = 0
	end
	return row
end

function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 2
	self.activePiece:setGridPosition(x, 0)
end

function Board:clearLast()
	self:forMatrix(function(my, mx)
		if self.gridMatrix[my][mx] == 1 then
			self.gridMatrix[my][mx] = 0
		end
	end)
end

function Board:update(dt)
	-- If timer exceeds fall delay, remove delay from timer and execute fall logic
	self.fallTimer = self.fallTimer + 10 * dt
	if self.fallTimer >= self.fallDelay then
		self.fallTimer = self.fallTimer - self.fallDelay
		local canMove = self:moveActive("Down")
		if not canMove then
			local cells = self:getActiveCells()
			for _, cell in ipairs(cells) do
				self.gridMatrix[cell.y][cell.x] = State.FULL
				self:spawnPiece(Tetronimo.random())
			end
		end
	end

	self:clearFullLines()

	--[[
	-- Update grid matrix
	self:clearLast()
	for _, cell in ipairs(self:getActiveCells()) do
		self.gridMatrix[cell.y][cell.x] = 1
	end
	--]]
end

function Board:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	local left, right, top, bottom = 0, self:getWidth(), 0, self:getHeight()

	-- Draw grid
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	self:forMatrix(function(my, mx)
		local x = (mx - 1) * CELL_SIZE
		local y = (my - 1) * CELL_SIZE
		love.graphics.rectangle("line", x, y, CELL_SIZE, CELL_SIZE)
		-- love.graphics.print(string.format("%d,%d", j, i), x, y)
	end)

	-- Draw filled cells
	self:forMatrix(function(my, mx)
		local x = (mx - 1) * CELL_SIZE
		local y = (my - 1) * CELL_SIZE
		if self.gridMatrix[my][mx] == State.FULL then
			love.graphics.setColor(0.35, 0.35, 1, 1)
			love.graphics.rectangle("fill", x, y, CELL_SIZE, CELL_SIZE)
		end
	end)

	-- Draw active piece
	self.activePiece:draw()

	-- Draw edges
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(left, top, left, bottom)
	love.graphics.line(right, top, right, bottom)
	love.graphics.line(left, bottom, right, bottom)

	love.graphics.pop()
end

---@param key love.KeyConstant
function Board:keypressed(key)
	if key == "left" then
		self:moveActive("Left")
	elseif key == "right" then
		self:moveActive("Right")
	end

	if key == "up" then
		self.fallTimer = self.fallDelay
		local moved = true
		while moved do
			moved = self:moveActive("Down")
		end
	elseif key == "down" then
		self:moveActive("Down")
	end

	if key == "x" then
		self.activePiece.matrix:rotate("Clockwise")
	elseif key == "z" then
		self.activePiece.matrix:rotate("CounterClockwise")
	end
end

function Board:getWidth()
	return self.cols * CELL_SIZE
end

function Board:getHeight()
	return self.rows * CELL_SIZE
end

function Board:getActiveCells()
	local cells = {}
	local t = self.activePiece
	local tx, ty = t:getGridPosition()

	t.matrix:forEach(function(mx, my, v)
		if v == State.FULL then
			local x = tx + mx - 1
			local y = ty + my - 1
			table.insert(cells, { x = x, y = y })
		end
	end)
	return cells
end

---@param dir direction
function Board:checkMove(dir)
	local activeCells = self:getActiveCells()
	for _, cell in ipairs(activeCells) do
		-- Process position to move to
		local x, y = cell.x, cell.y
		if dir == "Left" then
			x = cell.x - 1
		elseif dir == "Right" then
			x = cell.x + 1
		elseif dir == "Down" then
			y = cell.y + 1
		end

		-- Check if position is OOB
		if x < 1 or x > self.cols or y > self.rows then
			return false
		end
		-- Check if position is not empty
		if self.gridMatrix[y][x] ~= 0 then
			return false
		end
	end
	return true
end

---@param dir direction
function Board:moveActive(dir)
	local canMove = self:checkMove(dir)
	if canMove then
		self.activePiece:move(dir)
	end
	return canMove
end

function Board:clearFullLines()
	local isFull = false
	local matrix = self.gridMatrix

	for my = 1, #matrix do
		for mx = 1, #matrix[my] do
			isFull = self.gridMatrix[my][mx] == State.FULL
			if not isFull then
				break
			end
		end
		if isFull then
			Log:print(string.format("Line #%d is full", my))
			table.remove(matrix, my)
			table.insert(matrix, 1, self:initRow())
			isFull = false
		end
	end

	self.gridMatrix = matrix
end

return Board
