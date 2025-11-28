local Matrix = require("entities.matrix")
local Tetronimo = require("entities.tetronimo")
local CELL_SIZE = require("constants").CELL_SIZE

---@enum State
local State = {
	EMPTY = 0,
	FULL = 1,
}

---@class Board: Matrix
---@field activePiece Tetronimo
---@field fallDelay number
---@field fallTimer number
local Board = Matrix:extend()
Board.super = Matrix

---@return Board
function Board:new()
	Board.super.new(self, 20, 10, 0)
	self:spawnPiece(Tetronimo("T"))
	self.fallDelay = 6
	self.fallTimer = 0
	return self
end

function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 1
	self.activePiece:setGridPosition(x, 1)
end

function Board:update(dt)
	-- If timer exceeds fall delay, remove delay from timer and execute fall logic
	self.fallTimer = self.fallTimer + 10 * dt
	if self.fallTimer >= self.fallDelay then
		self.fallTimer = self.fallTimer - self.fallDelay
		local canMove = self:moveActive("Down")
		if not canMove then
			local cells = self:getActiveCells(self.activePiece)
			for _, cell in ipairs(cells) do
				pcall(self.setCell, self, cell.x, cell.y, State.FULL)
				self:spawnPiece(Tetronimo.random())
			end
		end
	end

	self:clearFullLines()
end

function Board:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	local left, right, top, bottom = 0, self:getWidth(), 0, self:getHeight()

	-- Draw grid
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	self:forEach(function(mx, my)
		local x = (mx - 1) * CELL_SIZE
		local y = (my - 1) * CELL_SIZE
		love.graphics.rectangle("line", x, y, CELL_SIZE, CELL_SIZE)
		-- love.graphics.print(string.format("%d,%d", j, i), x, y)
	end)

	-- Draw filled cells
	self:forEach(function(mx, my, v)
		local x = (mx - 1) * CELL_SIZE
		local y = (my - 1) * CELL_SIZE
		if v == State.FULL then
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

function Board:getWidth()
	return self.cols * CELL_SIZE
end

function Board:getHeight()
	return self.rows * CELL_SIZE
end

---@param t Tetronimo
function Board:getActiveCells(t)
	local tx, ty = t:getGridPosition()

	local cells = t:map(function(mx, my, v)
		if v == State.FULL then
			local x = tx + mx - 1
			local y = ty + my - 1
			return { x = x, y = y }
		end
	end)

	return cells
end

---@param dir direction
---@param t Tetronimo
function Board:checkMove(dir, t)
	local activeCells = self:getActiveCells(t)
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
		if self:getCell(x, y) ~= 0 then
			return false
		end
	end
	return true
end

---@param dir direction
function Board:moveActive(dir)
	local canMove = self:checkMove(dir, self.activePiece)
	if canMove then
		self.activePiece:move(dir)
	end
	return canMove
end

---@param rot rotation
function Board:checkRotation(rot)
	local t = self.activePiece
	local testPiece = t:copy()
	testPiece:rotate(rot)

	local activeCells = self:getActiveCells(testPiece)

	for _, cell in ipairs(activeCells) do
		local state = self:getCell(cell.x, cell.y)
		-- DEBUG
		-- Log:print(cell)
		if state == nil then
			return false
		elseif state ~= State.EMPTY or cell.x > self.cols or cell.x < 1 or cell.y > self.rows or cell.y < 1 then
			-- if state == State.FULL or state == nil then
			return false
		end
	end
	return true
end

function Board:clearFullLines()
	local isFull = false

	for my = 1, #self.matrix do
		for mx = 1, #self.matrix[my] do
			isFull = self:getCell(mx, my) == State.FULL
			if not isFull then
				break
			end
		end
		if isFull then
			Log:print(string.format("Line #%d is full", my))
			self:removeRow(my)
			self:insertRow(1, 0)
			isFull = false
		end
	end
end

return Board
