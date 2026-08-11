local Entity = require("class.entity.Entity")
local TetShapes = require("class.entity.Tetronimo").TetShapes
local Tetronimo = require("class.entity.Tetronimo").Tetronimo
local Cell = require("class.Cell")

local ANIMATION_SPEED = 25

---@class GrabBag
local GrabBag = Entity:extend()

function GrabBag:new()
	self.bag = self:newGrabBag()
	self.nextBag = self:newGrabBag()
	self.slideOffset = 0
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

---@param doAnimation? boolean
---@return Tetronimo
function GrabBag:takePiece(doAnimation)
	if doAnimation == nil then
		doAnimation = true
	end
	local piece = table.remove(self.bag, 1)
	if #self.bag == 0 then
		self.bag = self.nextBag
		self.nextBag = self:newGrabBag()
	end
	if doAnimation then
		self.slideOffset = Cell.SIZE * 3
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

function GrabBag:update(dt)
	if self.slideOffset > 0.01 then
		self.slideOffset = self.slideOffset - self.slideOffset * (ANIMATION_SPEED * dt)
	else
		self.slideOffset = 0
	end
end

function GrabBag:draw()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("NEXT")
	if self.slideOffset > 0 then
		love.graphics.translate(0, self.slideOffset)
	end
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
