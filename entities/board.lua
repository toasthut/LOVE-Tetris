local Entity = require("entities.entity")
local Tetronimo = require("entities.tetronimo")
local CELL_SIZE = require("constants").CELL_SIZE

---@class Board: Entity
---@field gridMatrix number[][]
local Board = Entity:extend()

---@return Board
function Board:new()
	---@diagnostic disable-next-line: undefined-field
	Board.super.new(self, 0, 0)
	self.cols = 10
	self.rows = 20

	self.gridMatrix = {}
	self:initGrid()

	self.activePiece = Tetronimo.random()
	self.fallDelay = 3
	self.fallTimer = 0

	return self
end

function Board:initGrid()
	self:forGrid(function(i, j)
		if not self.gridMatrix[j] then
			self.gridMatrix[j] = {}
		end
		self.gridMatrix[j][i] = 0
	end)
end

function Board:clearLast()
	self:forGrid(function(i, j)
		if self.gridMatrix[j][i] == 1 then
			self.gridMatrix[j][i] = 0
		end
	end)
end

function Board:update(dt)
	self.fallTimer = self.fallTimer + 10 * dt
	if self.fallTimer >= self.fallDelay then
		self.fallTimer = self.fallTimer - self.fallDelay
		local canMove = self:moveActive("Down")
		if not canMove then
			local cells = self:getActiveCells()
			for _, cell in ipairs(cells) do
				self.gridMatrix[cell.x][cell.y] = 2
				self.activePiece = Tetronimo.random()
			end
		end
	end

	-- Update grid matrix
	self:clearLast()
	for _, cell in ipairs(self:getActiveCells()) do
		self.gridMatrix[cell.x][cell.y] = 1
	end
end

function Board:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	local left, right, top, bottom = self:getSides()

	-- Draw grid
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	self:forGrid(function(i, j)
		local x = (j - 1) * CELL_SIZE
		local y = (i - 1) * CELL_SIZE
		love.graphics.rectangle("line", x, y, CELL_SIZE, CELL_SIZE)
		-- love.graphics.print(string.format("%d,%d", j, i), x, y)
	end)

	-- Draw filled cells
	self:forGrid(function(i, j)
		local x = (j - 1) * CELL_SIZE
		local y = (i - 1) * CELL_SIZE
		if self.gridMatrix[j][i] == 2 then
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

function Board:getSides()
	return 0, self:getWidth(), 0, self:getHeight()
end

function Board:getWidth()
	return self.cols * CELL_SIZE
end

function Board:getHeight()
	return self.rows * CELL_SIZE
end

---@param func function
function Board:forGrid(func)
	for i = 1, self.rows do
		for j = 1, self.cols do
			func(i, j)
		end
	end
end

function Board:getActiveCells()
	local cells = {}
	local t = self.activePiece
	local tx, ty = t:getGridPosition()
	for i, row in ipairs(t:getMatrix()) do
		for j, v in ipairs(row) do
			if v == 1 then
				local x = tx + j - 1
				local y = ty + i - 1
				table.insert(cells, { x = x, y = y })
			end
		end
	end
	return cells
end

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
		if self.gridMatrix[x][y] > 1 then
			return false
		end
	end
	return true
end

function Board:moveActive(dir)
	local canMove = self:checkMove(dir)
	if canMove then
		self.activePiece:move(dir)
	else
		Log:print("Can't move " .. dir)
	end
	return canMove
end

return Board
