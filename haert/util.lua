local util = {}

function util.contains(iterable, target)
	local pos = 0
	for i = 0, #iterable do
		if iterable[i] == target then
			pos = i
			break
		end
	end
	return pos
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

---@param t table
---@return table
function util.findAll(t, value)
	local filtered = {}
	for k, v in pairs(t) do
		if v == value then
			filtered[k] = v
		end
	end
	return filtered
end

---@param s string
---@return string
function util.trim(s)
	return s:match("^%s*(.-)%s*$")
end

---@param t table
---@return string
---@param tKey? string
function util.tableToString(t, tKey)
	local lines = util._tableToStringHelper(t, tKey)
	return table.concat(lines, "\n")
end

---@private
---@param t table
---@param tKey? string
---@param indent? string
---@return string[]
function util._tableToStringHelper(t, tKey, indent)
	indent = indent or ""
	local lines = {}
	local containsTable = false

	for _, v in pairs(t) do
		if type(v) == "table" then
			containsTable = true
			break
		end
	end

	if tKey ~= nil and tKey ~= "" then
		table.insert(lines, string.format("%s%s = {", indent, tKey))
	elseif containsTable then
		table.insert(lines, string.format("%s{", indent))
	end

	for k, v in pairs(t) do
		local keyStr = ""
		if type(k) == "string" then
			keyStr = k .. " = "
		end
		if type(v) ~= "table" then
			local str = string.format("%s%s%s,", indent, keyStr, tostring(v))
			table.insert(lines, str)
		else
			containsTable = true
			local t2 = util._tableToStringHelper(v, k, indent .. "  ")
			for i = 1, #t2 do
				table.insert(lines, t2[i])
			end
		end
	end

	table.insert(lines, string.format("%s},", indent))

	if not containsTable then
		for i = 1, #lines do
			lines[i] = util.trim(lines[i])
		end
		lines = { indent .. table.concat(lines, " ") }
	end

	return lines
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
		hex = hex:sub(1, 1) .. hex:sub(1, 1) .. hex:sub(2, 2) .. hex:sub(2, 2) .. hex:sub(3, 3) .. hex:sub(3, 3)
	end

	-- Convert hex pairs to numbers
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	r = r / 255
	g = g / 255
	b = b / 255
	return { r, g, b }
end

return util
