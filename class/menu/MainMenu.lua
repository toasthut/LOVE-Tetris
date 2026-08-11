local Menu = require("class.menu.Menu")
local Button = require("class.entity.Button")
local GAME_STATE = require("constants").GAME_STATE

---@class MainMenu: Menu
local MainMenu = Menu:extend()
MainMenu.super = Menu

---@param stateManager StateManager
function MainMenu:new(stateManager)
	local createButton = function(label, fn)
		return Button(0, 0, 120, 35, 3, label, fn)
	end

	local startBtn = createButton("Start", function()
		stateManager:changeState(GAME_STATE.ingame)
	end)
	local keybindsBtn = createButton("Keybinds", function()
		stateManager:changeState(GAME_STATE.keybinds)
	end)
	local exitBtn = createButton("Quit", function()
		love.event.quit()
	end)

	self.super.new(self, {
		startBtn,
		keybindsBtn,
		exitBtn,
	})
end

function MainMenu:draw()
	love.graphics.push()
	love.graphics.translate(10, 10)
	self.super.draw(self)
	love.graphics.pop()
end

return MainMenu
