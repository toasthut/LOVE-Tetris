io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
Audio = require("class.AudioManager")

local Logger = require("class.logger")
local Tetris = require("class.Tetris")

local LIMIT_FPS = false
local dt_accum = 0.0
local targetFPS = 24
local min_dt = 1 / targetFPS
local min_dt_x2 = min_dt * 2
local doDraw = true
local canvas = love.graphics.newCanvas(2560, 1440)

---@type Logger
Log = Logger()

local controlsText = {
	"Arrow keys to move",
	"Z/X to rotate",
	"LShift to hold",
}

local function render()
	Tetris:draw()
	Log:draw()
	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #controlsText do
		love.graphics.print(controlsText[i], 10, 10 + 16 * (i - 1))
	end
end

local function init()
	Tetris:new()
	love.audio.setVolume(Audio.mainVolume)
	love.resize()
end

function love.load()
	init()
end

---@param dt number
function love.update(dt)
	Tetris:update(dt)

	if not LIMIT_FPS then
		return
	end

	dt_accum = dt_accum + dt
	if dt_accum >= min_dt then
		dt_accum = dt_accum - min_dt
		if dt_accum > min_dt_x2 then
			dt_accum = min_dt
		end
		doDraw = true
	end
end

function love.draw()
	if not LIMIT_FPS then
		render()
		return
	end

	if doDraw then
		doDraw = false
		love.graphics.setCanvas(canvas)
		love.graphics.clear()
		render()
		love.graphics.setCanvas()
	end

	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(canvas)
	love.graphics.setBlendMode("alpha")
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
			init()
		end
	end

	if key == "q" then
		love.event.quit()
	end
end

function love.resize()
	local w, h = love.graphics.getDimensions()
	local bw, bh = Tetris.board:getDimensions()
	Tetris.board:setPosition(w / 2 - bw / 2, h / 2 - bh / 2)
end

---@alias rotation
---| "Clockwise"
---| "CounterClockwise"
---@alias deg90Interval
---| 0
---| 90
---| 180
---| 270
