io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
Audio = require("class.AudioManager")

local Logger = require("class.logger")
local Tetris = require("class.Tetris")

---@type Logger
Log = Logger()

---@alias rotation
---| "Clockwise"
---| "CounterClockwise"
---@alias deg90Interval
---| 0
---| 90
---| 180
---| 270

function love.load()
	love.audio.setVolume(Audio.mainVolume)
	Tetris:new()
	Log:clear()
end

---@param dt number
function love.update(dt)
	Tetris:update(dt)
end

local controlsText = {
	"Arrow keys to move",
	"Z/X to rotate",
	"LShift to hold",
}

function love.draw()
	Tetris:draw()
	Log:draw()

	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #controlsText do
		love.graphics.print(controlsText[i], 10, 10 + 16 * (i - 1))
	end
end

---@param key love.KeyConstant
function love.keypressed(key)
	Tetris:keypressed(key)
end
