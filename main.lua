io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")

local Board = require("class.entity.board")
local Keybind = require("class.keybind")
local Logger = require("class.logger")

---@type Logger
Log = Logger()

---@type Board
local board = Board()

---@type Keybind[]
local keybinds = {
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
			board.fallInterval:reset()
		end
	end, 0, 40),

	Keybind("up", function()
		board.activePiece = board:getGhost()
		board.fallInterval:forceTrigger()
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

	Keybind("lshift", function()
		if board.canHold then
			board:swapHoldPiece()
			board.canHold = false
		end
	end),

	Keybind("p", function()
		board.nCleared = board.nCleared + 1
		board:updateFallSpeed()
	end, true),

	Keybind("o", function()
		board:init(0)
	end),
}

function love.load()
	Log:clear()
	Log:print("game loaded")
	board:new()
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

local controlsText = {
	"Arrow keys to move",
	"Z/X to rotate",
	"LShift to hold",
}

function love.draw()
	board:draw()
	Log:draw()

	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #controlsText do
		love.graphics.print(controlsText[i], 10, 10 + 16 * (i - 1))
	end
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
end
