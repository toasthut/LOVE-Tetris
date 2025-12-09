local Board = require("class.entity.board")
local Keybind = require("class.keybind")

---@class Tetris
---@field board Board
---@field keybinds Keybind[]
---@field paused boolean
---@field pausekey Keybind
local Tetris = {}

function Tetris:new()
	self.board = Board()
	self.paused = false
	self:loadKeybinds()
	return self
end

function Tetris:update(dt)
	self.pausekey:update(dt)
	if not self.paused then
		for _, key in ipairs(self.keybinds) do
			key:update(dt)
		end
		self.board:update(dt)
	end
end

function Tetris:draw()
	self.board:draw()
end

function Tetris:loadKeybinds()
	self.keybinds = {
		Keybind("left", function()
			self.board:moveActive(-1, 0, true)
		end, true, nil, { "right" }),

		Keybind("right", function()
			self.board:moveActive(1, 0, true)
		end, true, nil, { "left" }),

		Keybind("down", function()
			self.board:softDrop()
		end, 0, 40),

		Keybind("up", function()
			self.board:hardDrop()
		end),

		Keybind("x", function()
			self.board:rotateActive("Clockwise")
		end),

		Keybind("z", function()
			self.board:rotateActive("CounterClockwise")
		end),

		Keybind("lshift", function()
			self.board:swapHoldPiece()
		end),

		Keybind("o", function()
			self.board:init(0)
		end),

		Keybind("=", function()
			Audio.volumeUp(0.05)
			Log:print(Audio.mainVolume)
		end),

		Keybind("-", function()
			Audio.volumeDown(0.05)
			Log:print(Audio.mainVolume)
		end),
	}

	for i = 1, 9 do
		local kb = Keybind(tostring(i), function()
			self.board:handleLineClear(i)
		end)
		table.insert(self.keybinds, kb)
	end

	self.pausekey = Keybind("p", function()
		self.paused = not self.paused
	end)
end

return Tetris
