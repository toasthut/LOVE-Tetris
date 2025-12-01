io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
switch = util.switch

local Board = require("class.entity.board")
local Keybind = require("class.keybind")
local Logger = require("class.logger")

---@type Logger
Log = Logger()
---@type Keybind[]
local keybinds = {}
---@type Board
local board

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

		Keybind("lshift", function()
			board:swapHoldPiece()
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
		love.graphics.print(controlsText[i], 10, -5 + (i * 16))
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

	if key == "p" then
		local activeCells = board.activePiece:getFullCells()
		for _, v in pairs(activeCells) do
			Log:print(v)
		end
	end
end
