local util = {}

function util.contains(iterable, target)
	local contains = false
	for i = 0, #iterable do
		if iterable[i] == target then
			contains = true
			break
		end
	end
	return contains
end

---@param t table
---@return table
function util.keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

function util.switch(value)
  return function(cases)
    local case = cases[value] or cases.default
    assert(case, string.format("Unhandled case (%s", value))
    return case(value)
  end
end

function util.hexToRGB(hex)
    -- Remove '#' if present
    hex = hex:gsub("#", "")

    -- Handle short hex (e.g. F53 → FF5533)
    if #hex == 3 then
        hex = hex:sub(1,1)..hex:sub(1,1) ..
              hex:sub(2,2)..hex:sub(2,2) ..
              hex:sub(3,3)..hex:sub(3,3)
    end

    -- Convert hex pairs to numbers
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)

    r = r / 255
    g = g / 255
    b = b / 255
    return { r, g, b }
end

return util
