local Entity = require("entities.entity")
local Tetronimo = require("entities.tetronimo")
local CELL_SIZE = require("constants").CELL_SIZE

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

	self:initGrid()

	self:spawnPiece(Tetronimo.random())
	self.fallDelay = 3
	self.fallTimer = 0
	return self
end

---@param func function
function Board:forGrid(func)
	for i = 1, self.rows do
		for j = 1, self.cols do
			func(i, j)
		end
	end
end

function Board:initGrid()
	self.gridMatrix = {}
	self:forGrid(function(i, j)
		if not self.gridMatrix[j] then
			self.gridMatrix[j] = {}
		end
		self.gridMatrix[j][i] = 0
	end)
end

function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 2
	self.activePiece:setGridPosition(x, 0)
end

function Board:clearLast()
	self:forGrid(function(i, j)
		if self.gridMatrix[j][i] == 1 then
			self.gridMatrix[j][i] = 0
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
				self.gridMatrix[cell.x][cell.y] = 2
				self:spawnPiece(Tetronimo.random())
			end
		end
	end

	--[[
	-- Update grid matrix
	self:clearLast()
	for _, cell in ipairs(self:getActiveCells()) do
		self.gridMatrix[cell.x][cell.y] = 1
	end
	--]]
end

function Board:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	local left, right, top, bottom = 0, self:getWidth(), 0, self:getHeight()

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
		if self.gridMatrix[x][y] ~= 0 then
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
	else
		Log:print("Can't move " .. dir)
	end
	return canMove
end

return Board
