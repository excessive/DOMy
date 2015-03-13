-- http://wiki.interfaceware.com/534.html
local function string_split(s, d)
	local magic = { "(", ")", ".", "%", "+", "-", "*", "?", "[", "^", "$" }
	for _, v in ipairs(magic) do
		if d == v then
			d = "%"..d
			break
		end
	end
	local t, i, f, match = {}, 0, nil, '(.-)' .. d .. '()'
	if string.find(s, d) == nil then return {s} end
	for sub, j in string.gmatch(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	if i ~= 0 then t[i+1] = string.sub(s, f) end
	return t
end

local Pseudo = {}

function Pseudo.checked(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.checked then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.disabled(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if not element.enabled then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.empty(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if #element.children == 0 then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.enabled(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.enabled then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.first_child(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and element.parent:first_child() == element then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.first_of_type(self, elements, value)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and element.type == value then
			for _, child in ipairs(element.parent.children) do
				if child.type == value then
					if child == element then
						table.insert(filter, element)
					end

					break
				end
			end

		end
	end

	return filter
end

function Pseudo.focus(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if self.pseudo.focus == element then
			table.insert(filter, element)
			break
		end
	end

	return filter
end

function Pseudo.hover(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if self.pseudo.hover == element then
			table.insert(filter, element)
			break
		end
	end

	return filter
end

function Pseudo.last_child(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and element.parent:last_child() == element then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.last_of_type(self, elements, value)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and element.type == value then
			local i = #element.parent.children

			while i > 1 do
				local child = element.parent.children[i]
				if child.type == value then
					if child == element then
						table.insert(filter, element)
					end

					break
				end

				i = i - 1
			end

		end
	end

	return filter
end

Pseudo["not"] = function(self, elements, value)
	local filter = {}
	value        = self:get_elements_by_query(value, elements)

	for _, element in ipairs(elements) do
		local found = false

		for _, t in ipairs(type) do
			if element == t then
				found = true
				break
			end
		end

		if not found then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.nth_child(self, elements, value)
	local filter = {}

	for _, element in ipairs(elements) do
		if #element.parent.children >= value then
			if element.parent.children[value] == element then
				table.insert(filter, element)
			end
		end
	end

	return filter
end

function Pseudo.nth_last_child(self, elements, value)
	local filter = {}

	for _, element in ipairs(elements) do
		if #element.parent.children >= value + 1 then
			if element.parent.children[#element.parent.children - value] == element then
				table.insert(filter, element)
			end
		end
	end

	return filter
end

function Pseudo.nth_last_of_type(self, elements, value)
	local filter = {}
	value        = string_split(value, ",")

	for _, element in ipairs(elements) do
		if element.parent and element.type == value[1] then
			local count = 0
			local i     = #element.parent.children

			while i > 1 do
				local child = element.parent.children[i]
				if child.type == value[1] then
					count = count + 1

					if child == element and count == value[2] then
						table.insert(filter, element)
					end

					if count == value[2] then break end
				end

				i = i - 1
			end

		end
	end

	return filter
end

function Pseudo.nth_of_type(self, elements, value)
	local filter = {}
	value        = string_split(value, ",")

	for _, element in ipairs(elements) do
		if element.parent and element.type == value[1] then
			local count = 0

			for _, child in ipairs(element.parent.children) do
				if child.type == value[1] then
					count = count + 1

					if child == element and count == value[2] then
						table.insert(filter, element)
					end

					if count == value[2] then break end
				end
			end
		end
	end

	return filter
end

function Pseudo.only_child(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and #element.parent.children == 1 then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.only_of_type(self, elements, value)
	local filter = {}

	for _, element in ipairs(elements) do
		if element.parent and element.type == value then
			local count = 0
			for _, child in ipairs(element.parent.children) do
				if child.type == value then
					count = count + 1
				end
			end

			if count == 1 then
				table.insert(filter, element)
			end
		end
	end

	return filter
end

function Pseudo.root(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if not element.parent then
			table.insert(filter, element)
		end
	end

	return filter
end

function Pseudo.lclick(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if  self.mouse_down.l == element
		and self.pseudo.hover == element then
			table.insert(filter, element)
			break
		end
	end

	return filter
end

function Pseudo.mclick(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if  self.mouse_down.m == element
		and self.pseudo.hover == element then
			table.insert(filter, element)
			break
		end
	end

	return filter
end

function Pseudo.rclick(self, elements)
	local filter = {}

	for _, element in ipairs(elements) do
		if  self.mouse_down.r == element
		and self.pseudo.hover == element then
			table.insert(filter, element)
			break
		end
	end

	return filter
end

return Pseudo
