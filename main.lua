io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
switch = util.switch

local Board = require("entities.board")

---@type Logger
Log = require("logger")()

---@type Board
local board

function love.load()
	Log:clear()
	Log:print("game loaded")
	board = Board()
end

---@param dt number
function love.update(dt)
	-- Center board in window
	board:setPosition(
		love.graphics.getWidth() / 2 - board:getWidth() / 2,
		love.graphics.getHeight() / 2 - board:getHeight() / 2
	)
	board:update(dt)
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
	board:keypressed(key)
	if key == "`" then
		Log:toggleVisibility()
	end

	if key == "r" then
		love.load()
	end

	if key == "q" then
		love.event.quit()
	end

	if key == "p" then
		local activeCells = board:getActiveCells()
		for _, v in pairs(activeCells) do
			Log:print(v)
		end
	end
end
