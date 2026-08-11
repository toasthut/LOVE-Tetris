---@class Menu: Object
local Menu = Object:extend()

local SPACING = 15

---@param buttons Button[]
function Menu:new(buttons)
	self.buttons = buttons
	local nextY = 0
	for i = 1, #self.buttons do
		local btn = self.buttons[i]
		btn:setPosition(btn.x, nextY)
		nextY = nextY + btn.height + SPACING
	end
end

function Menu:update(dt)
	for i = 1, #self.buttons do
		local btn = self.buttons[i]
		btn:update(dt)
	end
end

function Menu:draw()
	for i = 1, #self.buttons do
		local btn = self.buttons[i]
		btn:draw()
	end
end

return Menu
