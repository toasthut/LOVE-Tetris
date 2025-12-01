---@class Logger: Object
local Logger = Object:extend()

function Logger:new(visible)
	self.visible = visible or true
	self.msgs = {}
	self.color = { 1, 1, 1, 1 }
	self.maxMsgs = 40
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
		local opacityReduction = 7
		color[4] = (255 - opacityReduction * (i - 1)) / 255
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
	if #self.msgs > self.maxMsgs then
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
