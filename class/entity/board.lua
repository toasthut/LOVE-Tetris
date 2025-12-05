local Matrix = require("class.entity.matrix")
local Cell = require("class.cell")
local Tetronimo = require("class.entity.tetronimo").Tetronimo
local GrabBag = require("class.entity.grabBag")
local Interval = require("class.interval")
local Timer = require("class.timer")

local PALETTE = require("constants").PALETTE
local LOCK_RESET_LIMIT = 16
local LOCK_DELAY_TIME = 0.5

---@class Board: Matrix
---@field grabBag GrabBag
---@field activePiece Tetronimo
---@field holdPiece Tetronimo
---@field colorMatrix Matrix
---@field canHold boolean
---@field nCleared number
---@field fallInterval Interval
---@field lockDelay Timer
---@field lockDelayResets number
local Board = Matrix:extend()
Board.super = Matrix

function Board:new()
	Board.super.new(self, 20, 10, 0)
	self.level = 1
	self.nCleared = 0
	self.holdPiece = nil
	self.canHold = true
	self.grabBag = GrabBag()
	self.colorMatrix = Matrix(self.rows, self.cols, 0)
	self.lockDelay = Timer()
	self.lockDelayResets = 0
	self.fallInterval = Interval(0.0, function()
		self:moveActive("Down")
	end)
	self:updateGravity()
	self:spawnPiece(self.grabBag:takePiece())
end

---@param tetronimo Tetronimo
function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 1
	if self.activePiece.shape == "O" then
		x = x + 1
	end
	self.activePiece:setGridPosition(x, 1)
	self.lockDelayResets = 0
	self.lockDelay:stop()
	self.lockDelay:reset()
end

function Board:update(dt)
	self.fallInterval:update(dt)
	self.lockDelay:update(dt)

	if self.lockDelay.running then
		if self.lockDelay.time >= LOCK_DELAY_TIME or self.lockDelayResets >= LOCK_RESET_LIMIT then
			self.fallInterval:forceTrigger()
			self:lockPiece()
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
		local x = (mx - 1) * Cell.SIZE
		local y = (my - 1) * Cell.SIZE
		love.graphics.rectangle("line", x, y, Cell.SIZE, Cell.SIZE)
	end)

	-- Draw filled cells
	self:forEach(function(mx, my, v)
		local x = (mx - 1) * Cell.SIZE
		local y = (my - 1) * Cell.SIZE
		if v == Cell.STATE.FULL then
			local color = self.colorMatrix:getCell(mx, my)
			assert(type(color) == "table", string.format("Color matrix value at {%d,%d} is not a table", mx, my))
			Cell:draw(x, y, color)
		end
	end)

	-- Draw active piece & ghost
	local ghost = self:getGhost()
	ghost.color = PALETTE.cloud
	ghost.color[4] = 0.2
	ghost:draw()
	self.activePiece:draw()

	-- Draw edges
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(left, top, left, bottom)
	love.graphics.line(right, top, right, bottom)
	love.graphics.line(left, bottom, right, bottom)

	-- Draw score
	love.graphics.print("LINES CLEARED: " .. self.nCleared, 0, -20)

	-- Draw held piece
	love.graphics.push()
	love.graphics.translate(-Cell.SIZE * 6.5, Cell.SIZE * 1)
	love.graphics.print("HOLD", 0, -20)
	local w = Cell.SIZE * 5.5
	local h = Cell.SIZE * 3.5
	love.graphics.rectangle("line", 0, 0, w, h)
	if self.holdPiece ~= nil then
		local t = self.holdPiece
		local x = (w / 2) - (t.cols * Cell.SIZE / 2)
		local y = (h / 2) - (t.rows * Cell.SIZE / 2)
		t:setPosition(x, y)
		t:draw()
	end
	love.graphics.pop()

	-- Draw next pieces
	love.graphics.push()
	love.graphics.translate(self:getWidth() + Cell.SIZE * 1.5, 0)
	self.grabBag:draw()
	love.graphics.pop()

	love.graphics.pop()
end

function Board:getWidth()
	return self.cols * Cell.SIZE
end

function Board:getHeight()
	return self.rows * Cell.SIZE
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
---@return boolean
function Board:moveActive(dir)
	local canMove = self:checkMove(dir, self.activePiece)
	if canMove then
		self:tranformActive(function()
			return self.activePiece:move(dir)
		end)
	end
	return canMove
end

---@param rot rotation
---@return boolean
function Board:rotateActive(rot)
	local canRotate = self:checkRotation(rot)
	if canRotate then
		self:tranformActive(function()
			return self.activePiece:rotate(rot)
		end)
	end
	return canRotate
end

---@param transformFunc function
function Board:tranformActive(transformFunc)
	local result = transformFunc()
	local isGrounded = not self:checkMove("Down", self.activePiece)
	if isGrounded then
		self.lockDelay:start()
		self.lockDelayResets = self.lockDelayResets + 1
	else
		self.lockDelay:stop()
		self.lockDelayResets = 0
	end
	self.lockDelay:reset()
	return result
end

function Board:lockPiece()
	for _, cell in ipairs(self.activePiece:getFullCells()) do
		self:setCell(cell.x, cell.y, Cell.STATE.FULL)
		self.colorMatrix:setCell(cell.x, cell.y, self.activePiece.color)
	end
	self.canHold = true
	self:spawnPiece(self.grabBag:takePiece())
end

---@param rot rotation
function Board:checkRotation(rot)
	local t = self.activePiece
	local testPiece = t:copy()
	testPiece:rotate(rot)

	local activeCells = testPiece:getFullCells()

	for _, cell in ipairs(activeCells) do
		local state = self:getCell(cell.x, cell.y)
		if state == Cell.STATE.FULL or state == nil then
			return false
		end
	end
	return true
end

---@return boolean
function Board:clearFullLines()
	local isFull = false
	local linesCleared = 0

	for my = 1, #self.matrix do
		for mx = 1, #self.matrix[my] do
			isFull = self:getCell(mx, my) == Cell.STATE.FULL
			if not isFull then
				break
			end
		end
		if isFull then
			self:removeRow(my)
			self:insertRow(1, 0)
			self.colorMatrix:removeRow(my)
			self.colorMatrix:insertRow(1, 0)
			isFull = false
			linesCleared = linesCleared + 1
		end
	end
	if linesCleared > 0 then
		self.nCleared = self.nCleared + linesCleared
		self:updateGravity()
	end
	return linesCleared > 0
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

function Board:getLevel()
	return math.floor(self.nCleared / 10) + 1
end

function Board:updateGravity()
	local a = math.min(self:getLevel(), 20) - 1
	local len = (0.8 - (a * 0.007)) ^ a
	self.fallInterval:setLength(len)
end

return Board
