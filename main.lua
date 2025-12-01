io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
switch = util.switch

local Board = require("class.entity.board")
local Keybind = require("class.keybind")

---@type Logger
Log = require("class.logger")()

---@type Board
local board
---@type Keybind[]
local keybinds = {}

function love.load()
	Log:clear()
	Log:print("game loaded")
	board = Board()
	keybinds = {
		Keybind("left", function()
			if love.keyboard.isDown("right") then
				return
			end
			board:moveActive("Left")
		end, true),

		Keybind("right", function()
			if love.keyboard.isDown("left") then
				return
			end
			board:moveActive("Right")
		end, true),

		Keybind("down", function()
			local moved = board:moveActive("Down")
			if moved then
				board.fallTimer = 0
			end
		end, 0, 18),

		Keybind("up", function()
			local moved = true
			board.fallTimer = board.fallDelay
			while moved do
				moved = board:moveActive("Down")
			end
		end),

		Keybind("x", function()
			if board:checkRotation("Clockwise") then
				board.activePiece:rotate("Clockwise")
			end
		end),

		Keybind("z", function()
			if board:checkRotation("CounterClockwise") then
				board.activePiece:rotate("CounterClockwise")
			end
		end),
	}
end

---@param dt number
function love.update(dt)
	-- Center board in window
	board:setPosition(
		love.graphics.getWidth() / 2 - board:getWidth() / 2,
		love.graphics.getHeight() / 2 - board:getHeight() / 2
	)
	board:update(dt)
	for _, key in ipairs(keybinds) do
		key:update(dt)
	end
end

function love.draw()
	board:draw()
	Log:draw()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Arrow keys to move", 10, 10)
	love.graphics.print("Z/X to rotate", 10, 25)
end

---@param key love.KeyConstant
function love.keypressed(key)
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

	if key == "p" then
		local activeCells = board.activePiece:getFullCells()
		for _, v in pairs(activeCells) do
			Log:print(v)
		end
	end
end
