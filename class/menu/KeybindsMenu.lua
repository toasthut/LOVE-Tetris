local Menu = require("class.menu.Menu")
local Button = require("class.entity.Button")
local PALETTE = require("constants").PALETTE

---@alias keybindInfo {label: string, key: love.KeyConstant}

---@type table<string,keybindInfo[]>
local defaultMap = {
	moveLeft = {
		label = "Move Left",
		key = "left",
	},
	moveRight = {
		label = "Move Right",
		key = "right",
	},
	softDrop = {
		label = "Soft Drop",
		key = "down",
	},
	hardDrop = {
		label = "Hard Drop",
		key = "up",
	},
	rotateCW = {
		label = "Rotate Clockwise",
		key = "x",
	},
	rotateCCW = {
		label = "Rotate Counter-Clockwise",
		key = "z",
	},
	holdPiece = {
		label = "Hold Piece",
		key = "lshift",
	},
	restart = {
		label = "Quick Restart",
		key = "r",
	},
}

---@enum keymapOrder
local keymapOrder = {
	moveLeft = 1,
	moveRight = 2,
	softDrop = 3,
	hardDrop = 4,
	rotateCW = 5,
	rotateCCW = 6,
	holdPiece = 7,
	restart = 8,
}

---@class KeybindsMenu: Menu
---@field keymap table<string,love.KeyConstant>
---@field labels string[]
---@field buttons Button[]
---@field awaitingInput boolean
---@field selectedBind string
local KeybindsMenu = Menu:extend()
KeybindsMenu.super = Menu

function KeybindsMenu:new()
	local keymap = {}
	local labels = {}
	local buttons = {}

	for k, v in pairs(defaultMap) do
		local i = keymapOrder[k]
		keymap[k] = v.key
		labels[i] = v.label

		buttons[i] = Button(240, 0, 100, 35, 3, string.upper(v.key), function()
			self.awaitingInput = true
			self.selectedBind = k
			self.buttons[i].label = "..."
		end)
	end

	KeybindsMenu.super.new(self, buttons)
	self.keymap = keymap
	self.labels = labels
	self.awaitingInput = false
	self.selectedBind = ""
end

function KeybindsMenu:update(dt)
	self.super.update(self, dt)
end

function KeybindsMenu:draw()
	love.graphics.push()
	love.graphics.translate(10, 40)

	for i = 1, #self.buttons do
		local button = self.buttons[i]
		button:draw()
	end

	love.graphics.setColor(PALETTE.cloud)
	love.graphics.setFont(Fonts.button)
	for i = 1, #self.labels do
		local btn = self.buttons[i]
		local y = btn.y + btn.height / 2 - Fonts.button:getHeight() / 2
		local label = self.labels[i]
		love.graphics.printf(label, 0, y, 230, "right")
	end
	love.graphics.setNewFont()

	love.graphics.pop()
end

---@param key love.KeyConstant
function KeybindsMenu:keypressed(key)
	if self.awaitingInput then
		self.awaitingInput = false

		local k = self.selectedBind
		local i = keymapOrder[k]

		if key == "escape" then
			Log:print("escape pressed, rebind canceled.")
		else
			self.keymap[k] = key
			Log:print("action bound to " .. key .. " key")
		end

		self.buttons[i].label = string.upper(self.keymap[k])
		return true
	else
		return false
	end
end

function KeybindsMenu:saveBinds() end

return KeybindsMenu
