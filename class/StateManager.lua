local Board = require("class.entity.board")
local MainMenu = require("class.menu.MainMenu")
local KeybindsMenu = require("class.menu.KeybindsMenu")
local GAME_STATE = require("constants").GAME_STATE

---@class StateManager: Object
---@field board Board
---@field keybinds Keybind[]
---@field paused boolean
---@field pausekey Keybind
---@field state GAME_STATE
local StateManager = Object:extend()

function StateManager:new()
	self.paused = false
	self.dynamicbinds = {}
	self.mainMenu = MainMenu(self)
	self.keybindsMenu = KeybindsMenu()
	self.board = Board()

	self:changeState(GAME_STATE.ingame)
end

---@param state GAME_STATE
function StateManager:changeState(state)
	self.state = state
	if state == GAME_STATE.mainMenu then
	elseif state == GAME_STATE.keybinds then
	elseif state == GAME_STATE.ingame then
		self.board:new()
		self.board:setKeybinds(self.keybindsMenu.keymap)
		love.resize()
		-- self.dynamicbinds = self.board:getKeybinds()
	end
end

function StateManager:update(dt)
	-- Main menu state
	if self.state == GAME_STATE.mainMenu then
		self.mainMenu:update(dt)
	elseif self.state == GAME_STATE.keybinds then
		self.keybindsMenu:update(dt)
	-- Ingame state
	elseif self.state == GAME_STATE.ingame then
		if not self.paused then
			for _, key in ipairs(self.dynamicbinds) do
				key:update(dt)
			end
			self.board:update(dt)
		end
	end
end

function StateManager:draw()
	if self.state == GAME_STATE.mainMenu then
		self.mainMenu:draw()
	elseif self.state == GAME_STATE.keybinds then
		self.keybindsMenu:draw()
	elseif self.state == GAME_STATE.ingame then
		self.board:draw()
	end
end

function StateManager:keypressed(key)
	local consumeKey = false

	if key == "escape" then
		if self.state == GAME_STATE.ingame then
			self:changeState(GAME_STATE.mainMenu)
		elseif self.state == GAME_STATE.keybinds then
			if not self.keybindsMenu:keypressed(key) then
				self:changeState(GAME_STATE.mainMenu)
			end
		end
	end

	consumeKey = self.keybindsMenu:keypressed(key)
	if consumeKey then
		return true
	end

	return false
end

return StateManager
