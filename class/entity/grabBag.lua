local Entity = require("class.entity.entity")
local TetShapes = require("class.entity.tetronimo").TetShapes
local Tetronimo = require("class.entity.tetronimo").Tetronimo

---@class GrabBag
local GrabBag = Entity:extend()

function GrabBag:new()
	self.bag = self:newGrabBag()
	self.nextBag = self:newGrabBag()
end

function GrabBag:newGrabBag()
	local keys = util.keys(TetShapes)
	local bag = {}

	for _ = 1, #keys do
		local rand = love.math.random(#keys)
		local randomPiece = table.remove(keys, rand)
		table.insert(bag, randomPiece)
	end

	return bag
end

---@return Tetronimo
function GrabBag:takePiece()
	local piece = table.remove(self.bag, 1)
	if #self.bag == 0 then
		self.bag = self.nextBag
		self.nextBag = self:newGrabBag()
	end
	return Tetronimo(piece)
end

function GrabBag:getPieceList()
	local list = {}
	for _, v in ipairs(self.bag) do
		table.insert(list, v)
	end
	for _, v in ipairs(self.nextBag) do
		table.insert(list, v)
	end
	return list
end

function GrabBag:draw()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("NEXT")
	local pieceList = self:getPieceList()
	for i = 1, 6 do
		---@type Tetronimo
		local tet = Tetronimo(pieceList[i])
		tet:setGridPosition(1, i * 3 - 1)
		tet:draw()
	end

	love.graphics.pop()
end

return GrabBag
