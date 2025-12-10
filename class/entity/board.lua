local Matrix = require("class.entity.matrix")
local Cell = require("class.cell")
local Tetronimo = require("class.entity.tetronimo").Tetronimo
local GrabBag = require("class.entity.grabBag")
local IntervalCallback = require("class.timer.IntervalCallback")
local Stopwatch = require("class.timer.Stopwatch")
local Audio = require("class.AudioManager")
local Shaker = require("class.animation.Shaker")

local PALETTE = require("constants").PALETTE
local LOCK_RESET_LIMIT = 16
local LOCK_DELAY_TIME = 0.5

-- Precalculated math
---@type table<number, number>
local SLAM_MAGNITUDE = (function()
	local SLAM_FACTOR = Cell.SIZE * 0.35
	local t = {}
	for i = 1, 9 do
		local v = SLAM_FACTOR * (i ^ 1.11)
		t[i] = v
	end
	return t
end)()

---@type table<number, number>
local GRAVITY_MAGNITUDE = (function()
	local t = {}
	for i = 1, 20 do
		local v = (0.8 - ((i - 1) * 0.007)) ^ (i - 1)
		t[i] = v
	end
	return t
end)()

---@class Board: Matrix
---@field grabBag GrabBag
---@field activePiece Tetronimo
---@field holdPiece Tetronimo
---@field colorMatrix Matrix
---@field canHold boolean
---@field level number
---@field nCleared number
---@field fallInterval IntervalCallback
---@field lockDelay Stopwatch
---@field lockDelayResets number
---@field lowestY number
---@field slamOffset number
---@field shaker Shaker
local Board = Matrix:extend()
Board.super = Matrix

function Board:new()
	Board.super.new(self, 20, 10, 0)
	self.colorMatrix = Matrix(self.rows, self.cols, 0)
	self.slamOffset = 0.0
	self.level = 1
	self.nCleared = 0

	self.grabBag = GrabBag()
	self.holdPiece = nil
	self.canHold = true
	self.lowestY = 0

	self.lockDelay = Stopwatch()
	self.lockDelayResets = 0
	self.fallInterval = IntervalCallback(0.0, function()
		self:moveActive(0, 1)
	end)
	self:updateGravity()

	self.shaker = Shaker(20, 0.015, 5)

	self:spawnPiece(self.grabBag:takePiece())
end

---@param tetronimo Tetronimo
function Board:spawnPiece(tetronimo)
	self.activePiece = tetronimo
	local x = (self.cols / 2) - 1
	local y = 1
	if self.activePiece.shape == "O" then
		x = x + 1
	elseif self.activePiece.shape == "I" then
		y = 0
	end
	self.activePiece:setGridPosition(x, y)
	self:moveActive(0, 0)

	for _, cell in ipairs(self.activePiece:getCellGridPositions()) do
		if self:getCell(cell.x, cell.y) ~= Cell.STATE.EMPTY then
			self.gameover = true
		end
	end

	self.lowestY = y
	self.lockDelayResets = 0
end

function Board:update(dt)
	self.fallInterval:update(dt)
	self.lockDelay:update(dt)
	self.shaker:update(dt)

	if self.slamOffset > 0 then
		self.slamOffset = math.max(0, self.slamOffset - self.slamOffset * (7.5 * dt))
	end

	if self.lockDelay.running then
		if self.lockDelay:getTime() >= LOCK_DELAY_TIME or self.lockDelayResets >= LOCK_RESET_LIMIT then
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

	love.graphics.push()
	do
		love.graphics.translate(0, self.slamOffset)
		self.shaker:draw()

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
	end
	love.graphics.pop()

	-- Draw score
	love.graphics.print("LEVEL: " .. self.level, 0, -40)
	love.graphics.print("LINES CLEARED: " .. self.nCleared, 0, -20)

	-- Draw held piece
	love.graphics.push()
	do
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
	end
	love.graphics.pop()

	-- Draw next pieces
	love.graphics.push()
	do
		love.graphics.translate(self:getWidth() + Cell.SIZE * 1.5, 0)
		self.grabBag:draw()
	end
	love.graphics.pop()

	love.graphics.pop()

	if self.gameover then
		local text = "GAME OVER"
		local color = { love.graphics.getColor() }
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.setNewFont(64)
		local buh = { 1, -1, 2, -2 }
		for i = 1, #buh do
			for j = 1, #buh do
				love.graphics.print(
					text,
					love.graphics.getWidth() / 2 + buh[i],
					love.graphics.getHeight() / 2 + buh[j],
					0,
					1,
					1,
					love.graphics.getFont():getWidth(text) / 2,
					love.graphics.getFont():getHeight() / 2
				)
			end
		end

		love.graphics.setColor(color)
		love.graphics.print(
			text,
			love.graphics.getWidth() / 2,
			love.graphics.getHeight() / 2,
			0,
			1,
			1,
			love.graphics.getFont():getWidth(text) / 2,
			love.graphics.getFont():getHeight() / 2
		)
		love.graphics.setNewFont()
	end
end

function Board:getWidth()
	return self.cols * Cell.SIZE
end

function Board:getHeight()
	return self.rows * Cell.SIZE
end

function Board:getDimensions()
	return self:getWidth(), self:getHeight()
end

---@param x number
---@param y number
---@param t Tetronimo
function Board:checkMove(x, y, t)
	local activeCells = t:getCellGridPositions()
	for _, cell in ipairs(activeCells) do
		-- Process position to move to
		local nx = cell.x + x
		local ny = cell.y + y

		-- Check if position is OOB
		if nx < 1 or nx > self.cols or ny > self.rows then
			return false
		end
		-- Check if position is not empty
		if self:getCell(nx, ny) ~= 0 then
			return false
		end
	end
	return true
end

---@param rot rotation
function Board:checkRotation(rot)
	local t = self.activePiece
	local testPiece = t:copy()
	testPiece:rotate(rot)

	local activeCells = testPiece:getCellGridPositions()

	for _, cell in ipairs(activeCells) do
		local state = self:getCell(cell.x, cell.y)
		if state == Cell.STATE.FULL or state == nil then
			return false
		end
	end
	return true
end

---@param rot rotation
function Board:findRotationPosition(rot)
	local isValidPosition = true
	local validKick = false

	local t = self.activePiece:copy()
	t:rotate(rot)
	local tCells = t:getCellGridPositions()

	local degRotated = t.degreesRotated
	local kickList = Tetronimo.KICKS[rot][tostring(degRotated)]

	for i = 1, #kickList do
		isValidPosition = true
		for _, cell in ipairs(tCells) do
			local kx, ky = kickList[i][1], kickList[i][2]
			local state = self:getCell(cell.x + kx, cell.y + ky)
			if state == Cell.STATE.FULL or state == nil then
				isValidPosition = false
				break
			end
		end
		if isValidPosition then
			validKick = kickList[i]
			break
		end
	end
	return validKick
end

---@param x number
---@param y number
---@param playSound? boolean
---@return boolean
function Board:moveActive(x, y, playSound)
	local canMove = self:checkMove(x, y, self.activePiece)
	if canMove then
		self:tranformActive(function()
			return self.activePiece:move(x, y)
		end)
		if playSound and x ~= 0 then
			Audio.sfx.xMove:clone():play()
		elseif playSound and y ~= 0 then
			Audio.sfx.softDrop:clone():play()
			--[[
			local s = Audio.sfx.softDrop:clone()
			local _, ty = self.activePiece:getGridPosition()
			local min, max = 0.9, 1.1
			local pitch = ((self.rows - ty) / self.rows) * (max - min) + min
			Log:print(pitch)
			s:setPitch(pitch)
			s:play()
			--]]
		end
	end
	return canMove
end

---@param rot rotation
---@return boolean
function Board:rotateActive(rot)
	local pos = self:findRotationPosition(rot)
	if pos then
		self:tranformActive(function()
			local x, y = pos[1], pos[2]
			self.activePiece:move(x, y)
			self.activePiece:rotate(rot)
		end)
		Audio.sfx.rotate:clone():play()
	end
	return pos
end

---@param transformFunc function
function Board:tranformActive(transformFunc)
	local result = transformFunc()
	local isGrounded = not self:checkMove(0, 1, self.activePiece)
	if isGrounded then
		if not self.lockDelay.running then
			Audio.sfx.touchGround:play()
		end
		self.lockDelay:start()
		self.lockDelayResets = self.lockDelayResets + 1
	else
		self.lockDelay:pause()
	end

	local _, gy = self.activePiece:getGridPosition()
	if self.lowestY < gy then
		self.lowestY = gy
		if not isGrounded then
			self.lockDelayResets = 0
		end
	end

	self.lockDelay:reset()
	return result
end

function Board:lockPiece()
	for _, cell in ipairs(self.activePiece:getCellGridPositions()) do
		self:setCell(cell.x, cell.y, Cell.STATE.FULL)
		self.colorMatrix:setCell(cell.x, cell.y, self.activePiece.color)
	end
	self.canHold = true
	self.lockDelay:stop()
	self:spawnPiece(self.grabBag:takePiece())
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
		self:handleLineClear(linesCleared)
	end
	return linesCleared > 0
end

function Board:handleLineClear(nLines)
	self.nCleared = self.nCleared + nLines
	self:updateGravity()

	local lvl = self:getLevel()
	if lvl > self.level then
		self.level = lvl
		Audio.sfx.nextLevel:play()
	end
	Audio.sfx.lineClear:clone():play()

	local offset = SLAM_MAGNITUDE[nLines]
	self.slamOffset = self.slamOffset + offset
	self.shaker:play()
end

function Board:getGhost()
	local ghost = self.activePiece:copy()
	local nLoops = 0
	repeat
		local canMove = self:checkMove(0, 1, ghost)
		if canMove then
			ghost:move(0, 1)
		end
		nLoops = nLoops + 1
		assert(nLoops < 1000, "Infinite loop stopped.")
	until not canMove
	return ghost
end

function Board:swapHoldPiece()
	if self.canHold then
		local nextPiece
		if self.holdPiece ~= nil then
			nextPiece = Tetronimo(self.holdPiece.shape)
		else
			nextPiece = self.grabBag:takePiece()
		end
		self.holdPiece = Tetronimo(self.activePiece.shape)
		self:spawnPiece(nextPiece)
		self.canHold = false
		Audio.sfx.holdPiece:play()
	end
end

function Board:softDrop()
	local moved = self:moveActive(0, 1, true)
	if moved then
		self.fallInterval:reset()
	end
end

function Board:hardDrop()
	self.fallInterval:reset()
	self.activePiece = self:getGhost()
	self:lockPiece()
	Audio.sfx.hardDrop:clone():play()
	Audio.sfx.touchGround:play()
	self.slamOffset = self.slamOffset + SLAM_MAGNITUDE[1]
end

function Board:getLevel()
	return math.floor(self.nCleared / 10) + 1
end

function Board:updateGravity()
	local lvl = math.min(self:getLevel(), 20)
	local len = GRAVITY_MAGNITUDE[lvl]
	self.fallInterval:setLength(len)
end

return Board
