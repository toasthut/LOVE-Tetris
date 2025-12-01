local Matrix = require("class.entity.matrix")
local Tetronimo = require("class.entity.tetronimo").Tetronimo
local GrabBag = require("class.entity.grabBag")

local CellState = require("constants").CellState
local CELL_SIZE = require("constants").CELL_SIZE

---@class Board: Matrix
---@field grabBag GrabBag
---@field activePiece Tetronimo
---@field holdPiece Tetronimo
---@field fallDelay number
---@field fallTimer number
---@field colorMatrix Matrix
local Board = Matrix:extend()
Board.super = Matrix

function Board:new()
	Board.super.new(self, 20, 10, 0)
	self.grabBag = GrabBag()
	self.fallDelay = 6
	self.fallTimer = 0
	self.colorMatrix = Matrix(self.rows, self.cols, 0)
	self:spawnPiece(self.grabBag:takePiece())
	self.holdPiece = nil
end

---@param tetronimo Tetronimo
function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 1
	if self.activePiece.shape == "O" then
		x = x + 1
	end
	self.activePiece:setGridPosition(x, 1)
end

function Board:update(dt)
	-- If timer exceeds fall delay, remove delay from timer and execute fall logic
	self.fallTimer = self.fallTimer + 10 * dt
	if self.fallTimer >= self.fallDelay then
		self.fallTimer = self.fallTimer - self.fallDelay
		local canMove = self:moveActive("Down")

		if not canMove then
			local cells = self.activePiece:getFullCells()
			for _, cell in ipairs(cells) do
				pcall(self.setCell, self, cell.x, cell.y, CellState.FULL)
				self.colorMatrix:setCell(cell.x, cell.y, self.activePiece.color)
			end
			self:spawnPiece(self.grabBag:takePiece())
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
		if v == CellState.FULL then
			local color = self.colorMatrix:getCell(mx, my)
			assert(type(color) == "table", string.format("Color matrix value at {%d,%d} is not a table", mx, my))
			love.graphics.setColor(color)
			love.graphics.rectangle("fill", x, y, CELL_SIZE, CELL_SIZE)
		end
	end)

	-- Draw active piece & ghost
	self:getGhost():draw()
	self.activePiece:draw()

	-- Draw edges
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(left, top, left, bottom)
	love.graphics.line(right, top, right, bottom)
	love.graphics.line(left, bottom, right, bottom)

	-- Draw held piece
	love.graphics.push()
	love.graphics.translate(-CELL_SIZE * 6.5, CELL_SIZE * 1)
	love.graphics.print("HOLD", 0, -20)
	local w = CELL_SIZE * 5.5
	local h = CELL_SIZE * 3.5
	love.graphics.rectangle("line", 0, 0, w, h)
	if self.holdPiece ~= nil then
		local t = self.holdPiece
		local x = (w / 2) - (t.cols * CELL_SIZE / 2)
		local y = (h / 2) - (t.rows * CELL_SIZE / 2)
		t:setPosition(x, y)
		t:draw()
	end
	love.graphics.pop()

	-- Draw next pieces
	love.graphics.translate(self:getWidth() + CELL_SIZE * 1.5, 0)
	self.grabBag:draw()

	love.graphics.pop()
end

function Board:getWidth()
	return self.cols * CELL_SIZE
end

function Board:getHeight()
	return self.rows * CELL_SIZE
end

---@param dir direction
---@param t Tetronimo
function Board:checkMove(dir, t)
	local activeCells = t:getFullCells()
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

	local activeCells = testPiece:getFullCells()

	for _, cell in ipairs(activeCells) do
		local state = self:getCell(cell.x, cell.y)
		if state == CellState.FULL or state == nil then
			return false
		end
	end
	return true
end

function Board:clearFullLines()
	local isFull = false

	for my = 1, #self.matrix do
		for mx = 1, #self.matrix[my] do
			isFull = self:getCell(mx, my) == CellState.FULL
			if not isFull then
				break
			end
		end
		if isFull then
			Log:print(string.format("Line #%d is full", my))
			self:removeRow(my)
			self:insertRow(1, 0)
			self.colorMatrix:removeRow(my)
			self.colorMatrix:insertRow(1, 0)
			isFull = false
		end
	end
end

function Board:getGhost()
	local ghost = self.activePiece:copy()
	local nLoops = 0
	repeat
		local canMove = self:checkMove("Down", ghost)
		if canMove then
			ghost:move("Down")
		end
		nLoops = nLoops + 1
		assert(nLoops < 1000, "Infinite loop stopped.")
	until not canMove

	ghost.color = util.hexToRGB("666666")
	ghost.color[4] = 0.8
	return ghost
end

function Board:swapHoldPiece()
	local nextPiece
	if self.holdPiece ~= nil then
		nextPiece = Tetronimo(self.holdPiece.shape)
	else
		nextPiece = self.grabBag:takePiece()
	end
	self.holdPiece = Tetronimo(self.activePiece.shape)
	self:spawnPiece(nextPiece)
end

return Board
