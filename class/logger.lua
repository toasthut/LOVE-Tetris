---@class Logger: Object
local Logger = Object:extend()

local MAX_MSGS = 40
-- Precalculated math
local OPACITY_LEVEL = (function()
	local REDUCTION = 255 / 20
	local t = {}
	for i = 1, MAX_MSGS do
		local n = math.max(0, i - 5)
		local v = (255 - REDUCTION * n) / 255
		t[i] = v
	end
	return t
end)()

function Logger:new(visible)
	self.visible = visible or true
	self.msgs = {}
	self.color = { 1, 1, 1, 1 }
end

function Logger:draw()
	if not self.visible then
		return
	end

	love.graphics.push()
	for i, v in ipairs(self.msgs) do
		-- Print msgs from bottom of screen upwards
		local height = love.graphics:getHeight() - 5 - (15 * i)

		-- Reduce text opacity for older messages
		local color = self.color
		color[4] = OPACITY_LEVEL[i]
		love.graphics.setColor(color)

		love.graphics.print(v, 5, height)
	end
	love.graphics.pop()
end

function Logger:print(msg)
	local text = ""
	local timestamp = os.clock()

	-- Special formatting for tables
	if type(msg) == "table" then
		local tmp = {}
		for _, v in pairs(msg) do
			table.insert(tmp, v)
		end
		text = string.format("{%s}", table.concat(tmp, ","))
	else
		text = msg
	end

	local fulltext = string.format("%.3f: %s", timestamp, tostring(text))
	print(fulltext)
	table.insert(self.msgs, 1, fulltext)
	if #self.msgs > MAX_MSGS then
		table.remove(self.msgs, #self.msgs)
	end
end

function Logger:clear()
	self.msgs = {}
end

function Logger:toggleVisibility()
	self.visible = not self.visible
end

return Logger
