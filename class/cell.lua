local Cell = {}

Cell.SIZE = 24
Cell.STATE = {
	EMPTY = 0,
	FULL = 1,
	OOB = -1,
}
local INNER_SIZE = Cell.SIZE / 2.5
local INNER_OFFSET = Cell.SIZE / 2 - INNER_SIZE / 2

function Cell:draw(x, y, color)
	local darker = {}
	for i = 1, 3 do
		darker[i] = color[i] - 0.3
	end
	darker[4] = color[4]

	love.graphics.setColor(color)
	love.graphics.rectangle("fill", x, y, Cell.SIZE, Cell.SIZE)
	love.graphics.setColor(darker)
	love.graphics.rectangle("line", x, y, Cell.SIZE, Cell.SIZE)

	love.graphics.rectangle("fill", x + INNER_OFFSET, y + INNER_OFFSET, INNER_SIZE, INNER_SIZE)
end

return Cell
