local elements = {}
local GUI      = {}

-- https://github.com/stevedonovan/Penlight/blob/master/lua/pl/path.lua#L286
local function format_path(path)
	local np_gen1, np_gen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
	local np_pat1, np_pat2 = np_gen1:gsub('SEP', '/'), np_gen2:gsub('SEP', '/')
	local k

	repeat -- /./ -> /
		path, k = path:gsub(np_pat2, '/')
	until k == 0

	repeat -- A/../ -> (empty)
		path, k = path:gsub(np_pat1, '')
	until k == 0

	if path == '' then path = '.' end

	return path
end

function GUI:init(path)
	-- Load the default element classes
	local new_path      = path:gsub("%.", "/") .. "elements/"
	local element_files = love.filesystem.getDirectoryItems(new_path)

	for _, file in ipairs(element_files) do
		local name = file:sub(1, -5)
		elements[name] = love.filesystem.load(new_path .. file)(path)
	end

	self.elements = {}
end

function GUI:update(dt)

end

function GUI:draw()
	--!!! ALL OF THIS CODE IS TEMPORARY AND SUBJECT TO CHANGE !!!

	--[[         ~~ BOX MODEL ~~

	{                 WIDTH                 }
	+---------------------------------------+ ~~~
	|                MARGIN                 |
	|   +-------------------------------+   |
	|   |/////////// BORDER ////////////|   |
	|   |///+-----------------------+///|   |
	|   |///|        PADDING        |///|   |  H
	|   |///|   +---------------+   |///|   |  E
	|   |///|   |               |   |///|   |  I
	|   |///|   |    CONTENT    |   |///|   |  G
	|   |///|   |               |   |///|   |  H
	|   |///|   +---------------+   |///|   |  T
	|   |///|        PADDING        |///|   |
	|   |///+-----------------------+///|   |
	|   |/////////// BORDER ////////////|   |
	|   +-------------------------------+   |
	|                MARGIN                 |
	+---------------------------------------+ ~~~
	{                 WIDTH                 }

	--]]

	local function draw_element(element, x, y)
		local ep = element.properties

		-- TL position of element
		x = x or 0
		y = y or 0

		-- Full size of element
		local w = ep.width
		local h = ep.height

		-- Content start of element
		local sw = x + ep.padding[4] + ep.border[4] + ep.margin[4]
		local sh = y + ep.padding[1] + ep.border[1] + ep.margin[1]

		-- Content end of element
		local ew = x + w - (sw - w) - ep.padding[2] - ep.border[2] - ep.margin[2]
		local eh = y + h - (sh - h) - ep.padding[3] - ep.border[3] - ep.margin[3]

		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.printf(element.value, sw, sh, ew)

		-- Accumulated Child positions
		local cw = 0
		local ch = 0
		for _, child in ipairs(element.children) do
			local cp = child.properties

			if cp.display == "inline" then
				draw_element(child, sw+cw, sh)
			elseif cp.display == "block" then
				draw_element(child, sw, sh+ch)
			end

			cw = cw + child.properties.width
			ch = ch + child.properties.height
		end
	end

	-- Accumulated root positions
	local rw = 0
	local rh = 0
	for _, element in ipairs(self.elements) do
		if not element.parent then
			local ep = element.properties
			local d = ep.display
			if d == "inline" then
				draw_element(element, rw, 0)
			elseif d == "block" then
				draw_element(element, 0, rh)
			end

			rw = rw + ep.width
			rh = rh + ep.height
		end
	end
end

function GUI:import_markup(file)
	-- This function will return true if every key is a properly formatted table
	-- This does not take into account if the proposed element is a valid element
	local function check_syntax(t, root)
		for k, v in ipairs(t) do
			-- All elements in root must be tables
			if root and type(v) ~= "table" then
				print("Invalid root")
				return false
			end

			-- Key 1 is reserved for the element type
			if not root and k == 1 and type(v) ~= "string" then
				print("Invalid type")
				return false
			end

			-- Key 2 can be the element value or a child element
			if type(v) == "table" then
				if not check_syntax(v) then return false end
			elseif k > 2 then
				print("Invalid child")
				return false
			end
		end

		return true
	end

	-- Loops through the markup to generate element objects
	-- Assign parent and child relationships when necessary
	local function create_object(t, parent)
		for k, v in ipairs(t) do
			if type(v) == "table" then
				local object = self:new_element(v, parent)
				create_object(v, object)
			end
		end
	end

	local markup = love.filesystem.load(file)
	assert(markup, string.format("Markup file (%s) not found.", file))

	markup = markup()
	assert(check_syntax(markup, true), string.format("File (%s) contains invalid markup.", file))

	create_object(markup, false)
end

function GUI:import_styles(file)
	local styles = love.filesystem.load(file)
	assert(styles, string.format("Styles file (%s) not found.", file))

	styles = styles()
end

function GUI:import_scripts(file)
	local scripts = love.filesystem.load(file)
	assert(scripts, string.format("Scripts file (%s) not found.", file))

	scripts = scripts()
end

function GUI:new_element(element, parent, position)
	-- If we just want a default element, just pass in the element type!
	if type(element) == "string" then
		element = { element }
	end

	-- If no element type is found, don't create that element
	if not elements[element[1]] then return false end

	-- Create the element and insert it into the global elements list
	local object = setmetatable({}, { __index = elements[element[1]] })
	object:init(element, parent, self)
	table.insert(self.elements, object)

	-- If the element has a parent, send it along
	if parent then
		parent:add_child(object, position)
	end

	return object
end

function GUI:get_element_by_id(id)
	for _, element in ipairs(self.elements) do
		if element.id == id then
			return element
		end
	end

	return false
end

function GUI:get_elements_by_type(type, elements)
	elements = elements or self.elements

	local filter = {}

	for _, element in ipairs(elements) do
		if element.type == type then
			table.insert(filter, element)
		end
	end

	return filter
end

function GUI:get_elements_by_class(class, elements)
	elements = elements or self.elements

	local filter = {}

	for _, element in ipairs(elements) do
		for _, eclass in ipairs(element.class) do
			if eclass == class then
				table.insert(filter, element)
				break
			end
		end
	end

	return filter
end

function GUI:get_elements_by_query(query) -- CSS-stype selectors such as ".header > p"
end

function GUI:set_absolute_location(element)
end

return GUI
