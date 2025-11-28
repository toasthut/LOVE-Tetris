local physics = {}

local COLLIDER_TYPES = {
	RECTANGLE = "rectangle",
	CIRCLE = "circle",
}

---@param world love.World
---@param collider_type string
---@param shape_args table
---@param physic_args? table
function physics.newCollider(world, collider_type, shape_args, physic_args)
	physic_args = physic_args or {}

	local o = {}
	local _collider_type = COLLIDER_TYPES[collider_type:upper()]
	assert(_collider_type ~= nil, "Invalid Collider type '" .. collider_type .. "'")
	collider_type = _collider_type

	if collider_type == COLLIDER_TYPES.RECTANGLE then
		local x, y, w, h = unpack(shape_args)
		o.body = love.physics.newBody(world, x, y, "dynamic")
		o.shape = love.physics.newRectangleShape(w, h)
	elseif collider_type == COLLIDER_TYPES.CIRCLE then
		local x, y, r = unpack(shape_args)
		o.body = love.physics.newBody(world, x, y, "dynamic")
		o.shape = love.physics.newCircleShape(r)
	end

	o.collider_type = collider_type
	o.fixture = love.physics.newFixture(o.body, o.shape)

	local density, friction, restitution = unpack(physic_args, 1, 3)
	if density then
		o.fixture:setDensity(density)
	end
	if friction then
		o.fixture:setFriction(friction)
	end
	if restitution then
		o.fixture:setRestitution(restitution)
	end

	return o
end

return physics
