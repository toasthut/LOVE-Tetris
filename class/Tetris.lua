local Board = require("class.entity.board")
local Keybind = require("class.keybind")

---@class Tetris
---@field board Board
---@field keybinds Keybind[]
local Tetris = {}

function Tetris:new()
	self.board = Board()
	self:loadKeybinds()
	return self
end

function Tetris:update(dt)
	self.board:setPosition(
		love.graphics.getWidth() / 2 - self.board:getWidth() / 2,
		love.graphics.getHeight() / 2 - self.board:getHeight() / 2
	)
	self.board:update(dt)
	for _, key in ipairs(self.keybinds) do
		key:update(dt)
	end
end

function Tetris:draw()
	self.board:draw()
end

function Tetris:loadKeybinds()
	self.keybinds = {
		Keybind("left", function()
			if love.keyboard.isDown("right") then
				return
			end
			self.board:moveActive("Left")
		end, true),

		Keybind("right", function()
			if love.keyboard.isDown("left") then
				return
			end
			self.board:moveActive("Right")
		end, true),

		Keybind("down", function()
			local moved = self.board:moveActive("Down")
			if moved then
				self.board.fallInterval:reset()
			end
		end, 0, 40),

		Keybind("up", function()
			self.board.activePiece = self.board:getGhost()
			self.board:lockPiece()
		end),

		Keybind("x", function()
			self.board:rotateActive("Clockwise")
		end),

		Keybind("z", function()
			self.board:rotateActive("CounterClockwise")
		end),

		Keybind("lshift", function()
			if self.board.canHold then
				self.board:swapHoldPiece()
				self.board.canHold = false
			end
		end),

		Keybind("p", function()
			self.board.nCleared = self.board.nCleared + 1
			self.board:updateGravity()
		end, true),

		Keybind("o", function()
			self.board:init(0)
		end),
	}
end

---@param key love.KeyConstant
function Tetris:keypressed(key)
	if key == "`" then
		Log:toggleVisibility()
	end

	if key == "r" then
		if love.keyboard.isDown("lctrl") then
			love.event.quit("restart")
		else
			love.load()
		end
	end

	if key == "q" then
		love.event.quit()
	end
end

return Tetris
