io.stdout:setvbuf("no")

---@diagnostic disable: lowercase-global
Object = require("classic")
util = require("haert.util")
Audio = require("class.AudioManager")
Fonts = {
	default = love.graphics.getFont(),
	button = love.graphics.newFont(16),
	gameover = love.graphics.newFont(64),
}

local Logger = require("class.Logger")
---@type Logger
Log = Logger()

local StateManager = require("class.StateManager")

local LIMIT_FPS = false
local dt_accum = 0.0
local targetFPS = 24
local min_dt = 1 / targetFPS
local doDraw = true
local canvas = love.graphics.newCanvas(2560, 1440)

local function init()
	StateManager:new()
	love.audio.setVolume(Audio.mainVolume)
	love.resize()
end

local function render()
	StateManager:draw()
	Log:draw()
	love.graphics.setColor(1, 1, 1, 1)
end

function love.load()
	init()
end

---@param dt number
function love.update(dt)
	if dt > 60 then
		Log:print("Game took longer than a minute to update. Closing...")
		love.event.quit()
	end

	StateManager:update(dt)

	if not LIMIT_FPS then
		return
	end

	dt_accum = dt_accum + dt
	if dt_accum >= min_dt then
		dt_accum = dt_accum - min_dt
		if dt_accum > (min_dt * 2) then
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
	local consumeKey = false
	consumeKey = StateManager:keypressed(key)
	if consumeKey then
		return
	end

	if key == "`" then
		Log:toggleVisibility()
	end

	if key == "r" and love.keyboard.isDown("lctrl") then
		love.event.quit("restart")
	end

	if key == "q" then
		love.event.quit()
	end
end

function love.resize()
	local w, h = love.graphics.getDimensions()
	if StateManager.board then
		local bw, bh = StateManager.board:getDimensions()
		StateManager.board:setPosition(w / 2 - bw / 2, h / 2 - bh / 2)
	end
end

---@alias rotation
---| "Clockwise"
---| "CounterClockwise"
---@alias deg90Interval
---| 0
---| 90
---| 180
---| 270
