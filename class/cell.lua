local Cell = {}

Cell.SIZE = 24
Cell.STATE = {
	EMPTY = 0,
	FULL = 1,
}

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

	local smallCell = Cell.SIZE / 2.5
	local offset = Cell.SIZE / 2 - smallCell / 2
	love.graphics.rectangle("fill", x + offset, y + offset, smallCell, smallCell)
end

return Cell
